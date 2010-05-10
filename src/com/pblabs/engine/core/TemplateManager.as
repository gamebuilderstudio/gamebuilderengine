/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.core
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.debug.Profiler;
	import com.pblabs.engine.entity.IEntity;
	import com.pblabs.engine.entity.allocateEntity;
	import com.pblabs.engine.resource.ResourceManager;
	import com.pblabs.engine.resource.XMLResource;
	import com.pblabs.engine.serialization.Serializer;
	import com.pblabs.engine.serialization.TypeUtility;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	/**
	 * @eventType com.pblabs.engine.core.TemplateEvent.GROUP_LOADED
	 */
	[Event(name="GROUP_LOADED", type="com.pblabs.engine.core.TemplateEvent")]
	
	/**
	 * The template manager loads and unloads level files and stores information
	 * about their contents. The Serializer is used to deserialize object
	 * descriptions.
	 *
	 * <p>A level file can contain templates, entities, and groups. A template
	 * describes an entity that will be instantiated several times, like a
	 * bullet. Templates are left unnamed when they are instantiated.</p>
	 *
	 * <p>An entity describes a complete entity that is only instantiated once, like
	 * a background tilemap. Entities are named based on the name of the xml data
	 * that describes it.</p>
	 *
	 * <p>A group contains references to templates, entities, and other groups that
	 * should be instantiated when the group is instantiated.</p>
	 *
	 * @see com.pblabs.engine.serialization.Serializer.
	 */
	public class TemplateManager extends EventDispatcher
	{
		/**
		 * Defines the event to dispatch when a level file is successfully loaded.
		 */
		public static const LOADED_EVENT:String="LOADED_EVENT";

		/**
		 * Defines the event to dispatch when a level file fails to load.
		 */
		public static const FAILED_EVENT:String="FAILED_EVENT";

		/**
		 * Report every time we create an entity.
		 */
		public static var VERBOSE_LOGGING:Boolean=false;

        /**
         * Allow specifying an alternate class to use for IEntity.
         */
		public function set entityType(value:Class):void
		{
			_entityType=value;
		}

		/**
		 * Loads a level file and adds its contents to the template manager. This
		 * does not instantiate any of the objects in the file, it merely loads
		 * them for future instantiation.
		 *
		 * <p>When the load completes, the LOADED_EVENT will be dispatched. If
		 * the load fails, the FAILED_EVENT will be dispatched.</p>
		 *
		 * @param filename The file to load.
		 */
		public function loadFile(filename:String, forceReload:Boolean = false):void
		{
			PBE.resourceManager.load(filename, XMLResource, onLoaded, onFailed, forceReload);
		}

		/**
		 * Unloads a level file and removes its contents from the template manager.
		 * This does not destroy any entities that have been instantiated.
		 *
		 * @param filename The file to unload.
		 */
		public function unloadFile(filename:String):void
		{
			removeXML(filename);
			PBE.resourceManager.unload(filename, XMLResource);
		}

		/**
		 * Creates an instance of an object with the specified name. The name must
		 * refer to a template or entity. To instantiate groups, use instantiateGroup
		 * instead.
		 *
		 * @param name The name of the entity or template to instantiate. This
		 * corresponds to the name attribute on the template or entity tag in the XML.
		 *
		 * @return The created entity, or null if it wasn't found.
		 */
		public function instantiateEntity(name:String):IEntity
		{
			Profiler.enter("instantiateEntity");

			try
			{
				// Check for a callback.
				if (_things[name])
				{
					if (_things[name].groupCallback)
						throw new Error("Thing '" + name + "' is a group callback!");

					if (_things[name].entityCallback)
					{
						var instantiated:IEntity=_things[name].entityCallback();
						Profiler.exit("instantiateEntity");
						return instantiated;
					}
				}

				var xml:XML = getXML(name, "template", "entity");
				if (!xml)
				{
					Logger.error(this, "instantiateEntity", "Unable to find a template or entity with the name " + name + ".");
					Profiler.exit("instantiateEntity");
					return null;
				}

				var entity:IEntity=instantiateEntityFromXML(xml);
				Profiler.exit("instantiateEntity");
			}
			catch (e:Error)
			{
				Logger.error(this, "instantiateEntity", "Failed instantiating '" + name + "' due to: " + e.toString() + "\n" + e.getStackTrace());
				entity=null;
				Profiler.exit("instantiateEntity");
			}

			return entity;
		}

		/**
		 * Given an XML literal, construct a valid entity from it.
		 */
		public function instantiateEntityFromXML(xml:XML):IEntity
		{
			Profiler.enter("instantiateEntityFromXML");

			try
			{
                // Get at the name...
				var name:String = xml.attribute("name");
				if (xml.name() == "template")
					name = "";

                // And the alias...
				var alias:String=xml.attribute("alias");
				if (alias == "")
					alias = null;

                // Make the IEntity instance.
				var entity:IEntity;
				if (!_entityType)
					entity = allocateEntity();
				else
					entity = new _entityType();

                // To aid with reference handling, initialize FIRST but defer the
                // reset...
                entity.initialize(name, alias);
                entity.deferring = true;
                
                if (!doInstantiateTemplate(entity, xml.attribute("template"), new Dictionary()))
				{
					entity.destroy();
					Profiler.exit("instantiateEntityFromXML");
					return null;
				}

				Serializer.instance.deserialize(entity, xml);
				Serializer.instance.clearCurrentEntity();

                // Don't forget to disable deferring.
                entity.deferring = false;

				if (!_inGroup)
					Serializer.instance.reportMissingReferences();

				Profiler.exit("instantiateEntityFromXML");
			}
			catch (e:Error)
			{
				Logger.error(this, "instantiateEntity", "Failed instantiating '" + name + "' due to: " + e.toString() + "\n" + e.getStackTrace());
				entity=null;
				Profiler.exit("instantiateEntityFromXML");
			}

			return entity;
		}

		/**
		 * instantiates all templates or entities referenced by the specified group.
		 *
		 * @param name The name of the group to instantiate. This correspands to the
		 * name attribute on the group tag in the XML.
		 *
		 * @return An array containing all the instantiated objects. If the group
		 * wasn't found, the array will be empty.
		 */
		public function instantiateGroup(name:String):Array
		{
			// Check for a callback.
			if (_things[name])
			{
				if (_things[name].entityCallback)
					throw new Error("Thing '" + name + "' is an entity callback!");
				
				// We won't dispatch the GROUP_LOADED event here as it's the callback
				// author's responsibility.
				if (_things[name].groupCallback)
					return _things[name].groupCallback();
			}

			try
			{
				var group:Array=new Array();
				if (!doInstantiateGroup(name, group, new Dictionary()))
				{
					for each (var entity:IEntity in group)
						entity.destroy();

					return null;
				}
				
				if(hasEventListener(TemplateEvent.GROUP_LOADED))
					dispatchEvent(new TemplateEvent(TemplateEvent.GROUP_LOADED, name));
					
				return group;
			}
			catch (e:Error)
			{
				Logger.error(this, "instantiateGroup", "Failed to instantiate group '" + name + "' due to: " + e.toString());
				return null;
			}

			// Should never get here, one branch or the other of the try will take it.
			throw new Error("Somehow skipped both branches of group instantiation try/catch block!");
			return null;
		}

		/**
		 * Adds an XML description of a template, entity, or group to the template manager so
		 * it can be instantiated in the future.
		 *
		 * @param xml The xml to add.
		 * @param identifier A string by which this xml can be referenced. This is NOT the
		 * name of the object. It is used so the xml can be removed by a call to RemoveXML.
		 * @param version The version of the format of the added xml.
		 */
		public function addXML(xml:XML, identifier:String, version:int):void
		{
			var name:String=xml.attribute("name");

			if (name.length == 0)
			{
				Logger.warn(this, "AddXML", "XML object description added without a 'name' attribute.");
				return;
			}

			if (_things[name])
			{
				Logger.warn(this, "AddXML", "An XML object description with name " + name + " has already been added.");
				return;
			}

			var thing:ThingReference=new ThingReference();
			thing.xmlData=xml;
			thing.identifier=identifier;
			thing.version=version;

			_things[name]=thing;
		}

		/**
		 * Removes the specified object from the template manager.
		 *
		 * @param identifier This is NOT the name of the xml object. It is the value
		 * passed as the identifier in AddXML.
		 */
		public function removeXML(identifier:String):void
		{

			var thingsToDelete:Array=new Array();

			for (var name:String in _things)
			{
				var thing:ThingReference=_things[name];
				if (thing.identifier == identifier)
					thingsToDelete[thingsToDelete.length]=name;
			}

			// delete elements marked for deletion
			for (var i:int=0; i < thingsToDelete.length; i++)
			{
				_things[thingsToDelete[i]]=null;
				delete _things[thingsToDelete[i]];
			}

		}

		/**
		 * Gets a previously added xml description that has the specified name.
		 *
		 * @param name The name of the xml to retrieve.
		 * @param xmlType1 The type (template, entity, or group) the xml must be.
		 * If this is null, it can be anything.
		 * @param xmlType2 Another type (template, entity, or group) the xml can
		 * be.
		 *
		 * @return The xml description with the specified name, or null if it wasn't
		 * found.
		 */
		public function getXML(name:String, xmlType1:String=null, xmlType2:String=null):XML
		{
			var thing:ThingReference=doGetXML(name, xmlType1, xmlType2);
			return thing ? thing.xmlData : null;
		}

		/**
		 * Check if a template method by the provided name has been registered.
		 * @param name Name of the template registered with the TemplateManager
		 * @return true if the template exists, false if it does not.
		 */		
		public function hasEntityCallback(name:String):Boolean
		{
			return _things[name];
		}
		
		/**
		 * Register a callback-powered entity with the TemplateManager. Instead of
		 * parsing and returning an entity based on XML, this lets you directly
		 * create the entity from a function you specify.
		 *
		 * Generally, we recommend using XML for entity definitions, but this can
		 * be useful for reducing external dependencies, or providing special
		 * functionality (for instance, a single name that returns several
		 * possible entities based on chance).
		 *
		 * @param name Name of the entity.
		 * @param callback A function which takes no arguments and returns an IEntity.
		 * @see UnregisterEntityCallback, RegisterGroupCallback, hasEntityCallback
		 */
		public function registerEntityCallback(name:String, callback:Function):void
		{
			if (callback == null)
				throw new Error("Must pass a callback function!");

			if (_things[name])
				throw new Error("Already have a thing registered under '" + name + "'!");

			var newThing:ThingReference=new ThingReference();
			newThing.entityCallback=callback;
			_things[name]=newThing;
		}

		/**
		 * Unregister a callback-powered entity registered with RegisterEntityCallback.
		 * @see RegisterEntityCallback
		 */
		public function unregisterEntityCallback(name:String):void
		{
			if (!_things[name])
			{
				Logger.warn(this, "unregisterEntityCallback", "No such template '" + name + "'!");
				return;
			}

			if (!_things[name].entityCallback)
				throw new Error("Thing '" + name + "' is not an entity callback!");

			_things[name]=null;
			delete _things[name];
		}

		/**
		 * Register a function as a group. When the group is requested via instantiateGroup,
		 * the function is called, and the Array it returns is given to the user.
		 *
		 * @param name NAme of the group.
		 * @param callback A function which takes no arguments and returns an array of IEntity instances.
		 * @see UnregisterGroupCallback, RegisterEntityCallback
		 */
		public function registerGroupCallback(name:String, callback:Function):void
		{
			if (callback == null)
				throw new Error("Must pass a callback function!");

			if (_things[name])
				throw new Error("Already have a thing registered under '" + name + "'!");

			var newThing:ThingReference=new ThingReference();
			newThing.groupCallback=callback;
			_things[name]=newThing;
		}

		/**
		 * Unregister a function-based group registered with RegisterGroupCallback.
		 * @param name Name passed to RegisterGroupCallback.
		 * @see RegisterGroupCallback
		 */
		public function unregisterGroupCallback(name:String):void
		{
			if (!_things[name])
				throw new Error("No such thing '" + name + "'!");

			if (!_things[name].groupCallback)
				throw new Error("Thing '" + name + "' is not a group callback!");

			_things[name]=null;
			delete _things[name];
		}

		private function doGetXML(name:String, xmlType1:String, xmlType2:String):ThingReference
		{
			var thing:ThingReference=_things[name];
			if (!thing)
				return null;

			// No XML on callbacks.
			if (thing.entityCallback != null || thing.groupCallback != null)
				return null;

			if (xmlType1)
			{
				var type:String=thing.xmlData.name();
				if (type != xmlType1 && type != xmlType2)
					return null;
			}

			return thing;
		}

		private function doInstantiateTemplate(object:IEntity, templateName:String, tree:Dictionary):Boolean
		{
			if (templateName == null || templateName.length == 0)
				return true;

			if (tree[templateName])
			{
				Logger.warn(this, "instantiateTemplate", "Cyclical template detected. " + templateName + " has already been instantiated.");
				return false;
			}

			var templateXML:XML=getXML(templateName, "template");
			if (!templateXML)
			{
				Logger.warn(this, "instantiate", "Unable to find the template " + templateName + ".");
				return false;
			}

			tree[templateName]=true;
			if (!doInstantiateTemplate(object, templateXML.attribute("template"), tree))
				return false;

			object.deserialize(templateXML, false);

			return true;
		}

		private function doInstantiateGroup(name:String, group:Array, tree:Dictionary):Boolean
		{
			var xml:XML=getXML(name, "group");
			if (!xml)
				throw new Error("Could not find group '" + name + "'");
                
            //Create the group:
            var actualGroup:PBGroup = new PBGroup();
            if(name != PBE.rootGroup.name)
            {
                actualGroup.initialize(name);
                actualGroup.owningGroup = PBE.currentGroup;
            }
            else
            {
                actualGroup = PBE.rootGroup;
            }

            var oldGroup:PBGroup = PBE.currentGroup;
            PBE.currentGroup = actualGroup;    
            
			for each (var objectXML:XML in xml.*)
			{
				var childName:String=objectXML.attribute("name");
				if (objectXML.name() == "groupReference")
				{
					if (tree[childName])
						throw new Error("Cyclical group detected. " + childName + " has already been instantiated.");

					tree[childName]=true;

					// Don't need to check for return value, as it will throw an error 
					// if something bad happens.
					try
					{
						if (!doInstantiateGroup(childName, group, tree))
							return false;
					}
					catch (err:*)
					{
						Logger.warn(this, "instantiateGroup", "Failed to instantiate group '" + childName + "' from groupReference in '" + name + "' due to: " + err);
						return false;
					}
				}
				else if (objectXML.name() == "objectReference")
				{
					_inGroup = true;
					group.push(instantiateEntity(childName));
					_inGroup=false;
				}
				else
				{
					Logger.warn(this, "instantiateGroup", "Encountered unknown tag " + objectXML.name() + " in group.");
				}
			}
            
            PBE.currentGroup = oldGroup;

			Serializer.instance.reportMissingReferences();

			return true;
		}

		private function onLoaded(resource:XMLResource):void
		{
			var version:int=resource.XMLData.attribute("version");
			var thingCount:int=0;
			for each (var xml:XML in resource.XMLData.*)
			{
				thingCount++;
				addXML(xml, resource.filename, version);
			}

			Logger.print(this, "Loaded " + thingCount + " from " + resource.filename);

			dispatchEvent(new Event(LOADED_EVENT));
		}

		private function onFailed(resource:XMLResource):void
		{
			dispatchEvent(new Event(FAILED_EVENT));
		}

		private var _inGroup:Boolean=false;
		private var _entityType:Class=null;
		private var _things:Dictionary=new Dictionary();
	}
}

/**
 * Helper class to store information about each thing.
 */
class ThingReference
{
	public var version:int=0;
	public var xmlData:XML=null;
	public var entityCallback:Function=null;
	public var groupCallback:Function=null;
	public var identifier:String="";
}
