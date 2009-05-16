/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Engine.Core
{
   import PBLabs.Engine.Entity.AllocateEntity;
   import PBLabs.Engine.Entity.IEntity;
   import PBLabs.Engine.Debug.Logger;
   import PBLabs.Engine.Resource.ResourceManager;
   import PBLabs.Engine.Resource.XMLResource;
   import PBLabs.Engine.Serialization.Serializer;
   import PBLabs.Engine.Serialization.TypeUtility;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
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
    * @see PBLabs.Engine.Serialization.Serializer.
    */
   public class TemplateManager extends EventDispatcher
   {
      /**
       * Defines the event to dispatch when a level file is successfully loaded.
       */
      public static const LOADED_EVENT:String = "LOADED_EVENT";
      
      /**
       * Defines the event to dispatch when a level file fails to load.
       */
      public static const FAILED_EVENT:String = "FAILED_EVENT";
      
      /**
       * Report every time we create an entity.
       */
      public static var VERBOSE_LOGGING:Boolean = false;
      
      /**
       * The singleton TemplateManager instance.
       */
      public static function get Instance():TemplateManager
      {
         if (_instance == null)
            _instance = new TemplateManager();
         
         return _instance;
      }
      
      private static var _instance:TemplateManager = null;
      
      public function set EntityType(type:Class):void
      {
         _entityType = type;
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
      public function LoadFile(filename:String):void
      {
         ResourceManager.Instance.Load(filename, XMLResource, _OnLoaded, _OnFailed);
      }
      
      /**
       * Unloads a level file and removes its contents from the template manager.
       * This does not destroy any entities that have been instantiated.
       * 
       * @param filename The file to unload.
       */
      public function UnloadFile(filename:String):void
      {
         RemoveXML(filename);
         ResourceManager.Instance.Unload(filename, XMLResource);
      }
      
      /**
       * Creates an instance of an object with the specified name. The name must
       * refer to a template or entity. To instantiate groups, use InstantiateGroup
       * instead.
       * 
       * @param name The name of the entity or template to instantiate. This
       * corresponds to the name attribute on the template or entity tag in the XML.
       * 
       * @return The created entity, or null if it wasn't found.
       */
      public function InstantiateEntity(name:String):IEntity
      {
         // Check for a callback.
         if(_things[name])
         {
            if(_things[name].GroupCallback)
               throw new Error("Thing '" + name + "' is a group callback!");
            if(_things[name].EntityCallback)
               return _things[name].EntityCallback();
         }
         
         var xml:XML = GetXML(name, "template", "entity");
         if (xml == null)
         {
            Logger.PrintError(this, "InstantiateEntity", "Unable to find a template or entity with the name " + name + ".");
            return null;
         }
         
         var name:String = xml.attribute("name");
         if (xml.name() == "template")
            name = "";
         
         var entity:IEntity;
         if (_entityType == null)
            entity = AllocateEntity();
         else
            entity = new _entityType();
         
         entity.Initialize(name);
         
         if (!_InstantiateTemplate(entity, xml.attribute("template"), new Dictionary()))
         {
            entity.Destroy();
            return null;
         }
         
         Serializer.Instance.Deserialize(entity, xml);
         Serializer.Instance.ClearCurrentEntity();
         
         if (!_inGroup)
            Serializer.Instance.ReportMissingReferences();
         
         return entity;
      }
      
      /**
       * Instantiates all templates or entities referenced by the specified group.
       * 
       * @param name The name of the group to instantiate. This correspands to the
       * name attribute on the group tag in the XML.
       * 
       * @return An array containing all the instantiated objects. If the group
       * wasn't found, the array will be empty.
       */
      public function InstantiateGroup(name:String):Array
      {
         // Check for a callback.
         if(_things[name])
         {
            if(_things[name].EntityCallback)
               throw new Error("Thing '" + name + "' is an entity callback!");
            if(_things[name].GroupCallback)
               return _things[name].GroupCallback();
         }

         try
         {
            var group:Array = new Array();
            if (!_InstantiateGroup(name, group, new Dictionary()))
            {
               for each (var entity:IEntity in group)
                  entity.Destroy();
               
               return null;
            }
            
            return group;            
         }
         catch (e:Error)
         {
            Logger.PrintError(this, "InstantiateGroup", "Failed to instantiate group '" + name + "' due to: " + e.toString());
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
      public function AddXML(xml:XML, identifier:String, version:int):void
      {
         var name:String = xml.attribute("name");
         if (name.length == 0)
         {
            Logger.PrintWarning(this, "AddXML", "XML object description added without a 'name' attribute.");
            return;
         }
         
         if (_things[name] != null)
         {
            Logger.PrintWarning(this, "AddXML", "An XML object description with name " + name + " has already been added.");
            return;
         }
         
         var thing:ThingReference = new ThingReference();
         thing.XMLData = xml;
         thing.Identifier = identifier;
         thing.Version = version;
         
         _things[name] = thing;
      }
      
      /**
       * Removes the specified object from the template manager.
       * 
       * @param identifier This is NOT the name of the xml object. It is the value
       * passed as the identifier in AddXML.
       */
      public function RemoveXML(identifier:String):void
      {
         for (var name:String in _things)
         {
            var thing:ThingReference = _things[name];
            if (thing.Identifier == identifier)
            {
               _things[name] = null;
               delete _things[name];
            }
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
      public function GetXML(name:String, xmlType1:String = null, xmlType2:String = null):XML
      {
         var thing:ThingReference = _GetXML(name, xmlType1, xmlType2);
         return thing != null ? thing.XMLData : null;
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
       * @see UnregisterEntityCallback, RegisterGroupCallback
       */
      public function RegisterEntityCallback(name:String, callback:Function):void
      {
         if (callback == null)
            throw new Error("Must pass a callback function!");
         
         if (_things[name])
            throw new Error("Already have a thing registered under '" + name + "'!");
         
         var newThing:ThingReference = new ThingReference();
         newThing.EntityCallback = callback;
         _things[name] = newThing;
      }
      
      /**
       * Unregister a callback-powered entity registered with RegisterEntityCallback.
       * @see RegisterEntityCallback
       */
      public function UnregisterEntityCallback(name:String):void
      {
         if (!_things[name])
            throw new Error("No such thing '" + name + "'!");
            
         if (!_things[name].EntityCallback)
            throw new Error("Thing '" + name + "' is not an entity callback!");
         
         _things[name] = null;
         delete _things[name];
      }
      
      /**
       * Register a function as a group. When the group is requested via InstantiateGroup,
       * the function is called, and the Array it returns is given to the user.
       *
       * @param name NAme of the group.
       * @param callback A function which takes no arguments and returns an array of IEntity instances.
       * @see UnregisterGroupCallback, RegisterEntityCallback
       */
      public function RegisterGroupCallback(name:String, callback:Function):void
      {
         if (callback == null)
            throw new Error("Must pass a callback function!");
         
         if (_things[name])
            throw new Error("Already have a thing registered under '" + name + "'!");
         
         var newThing:ThingReference = new ThingReference();
         newThing.GroupCallback = callback;
         _things[name] = newThing;
      }
      
      /**
       * Unregister a function-based group registered with RegisterGroupCallback.
       * @param name Name passed to RegisterGroupCallback.
       * @see RegisterGroupCallback
       */
      public function UnregisterGroupCallback(name:String):void
      {
         if (!_things[name])
            throw new Error("No such thing '" + name + "'!");
         
         if (!_things[name].GroupCallback)
            throw new Error("Thing '" + name + "' is not a group callback!");
         
         _things[name] = null;
         delete _things[name];
      }
      
      private function _GetXML(name:String, xmlType1:String, xmlType2:String):ThingReference
      {
         var thing:ThingReference = _things[name];
         if (thing == null)
            return null;
         
         // No XML on callbacks.
         if ((thing.EntityCallback != null) || (thing.GroupCallback != null))
            return null;
            
         if (xmlType1 != null)
         {
            var type:String = thing.XMLData.name();
            if ((type != xmlType1) && (type != xmlType2))
               return null;
         }
         
         return thing;
      }
      
      private function _InstantiateTemplate(object:IEntity, templateName:String, tree:Dictionary):Boolean
      {
         if ((templateName == null) || (templateName.length == 0))
            return true;
         
         if (tree[templateName] != null)
         {
            Logger.PrintWarning(this, "InstantiateTemplate", "Cyclical template detected. " + templateName + " has already been instantiated.");
            return false;
         }
         
         var templateXML:XML = GetXML(templateName, "template");
         if (templateXML == null)
         {
            Logger.PrintWarning(this, "Instantiate", "Unable to find the template " + templateName + ".");
            return false;
         }
         
         tree[templateName] = true;
         if (!_InstantiateTemplate(object, templateXML.attribute("template"), tree))
            return false;
         
         object.Deserialize(templateXML, false);
         
         return true;
      }
      
      private function _InstantiateGroup(name:String, group:Array, tree:Dictionary):Boolean
      {
         var xml:XML = GetXML(name, "group");
         if (xml == null)
            throw new Error("Could not find group '" + name + "'");
         
         for each(var objectXML:XML in xml.*)
         {
            var childName:String = objectXML.attribute("name");
            if (objectXML.name() == "groupReference")
            {
               if (tree[childName] != null)
                  throw new Error("Cyclical group detected. " + childName + " has already been instantiated.");
               
               tree[childName] = true;
               
               // Don't need to check for return value, as it will throw an error 
               // if something bad happens.
               try
               {
                  if(!_InstantiateGroup(childName, group, tree))
                     return false;               
               }
               catch(err:*)
               {
                  Logger.PrintWarning(this, "InstantiateGroup", "Failed to instantiate group '" + childName + "' from groupReference in '" + name + "' due to: " + err);
                  return false;
               }
            }
            else if (objectXML.name() == "objectReference")
            {
               _inGroup = true;
               group.push(InstantiateEntity(childName));
               _inGroup = false;
            }
            else
            {
               Logger.PrintWarning(this, "InstantiateGroup", "Encountered unknown tag " + objectXML.name() + " in group.");
            }
         }
         
         Serializer.Instance.ReportMissingReferences();
         
         return true;
      }
      
      private function _OnLoaded(resource:XMLResource):void
      {
         var version:int = resource.XMLData.attribute("version");
         var thingCount:int = 0;
         for each(var xml:XML in resource.XMLData.*)
         {
            thingCount++;
            AddXML(xml, resource.Filename, version);
         }
         
         Logger.Print(this, "Loaded " + thingCount + " from " + resource.Filename);
         
         dispatchEvent(new Event(LOADED_EVENT));
      }
      
      private function _OnFailed(resource:XMLResource):void
      {
         dispatchEvent(new Event(FAILED_EVENT));
      }
      
      private var _inGroup:Boolean = false;
      private var _entityType:Class = null;
      private var _things:Dictionary = new Dictionary();
   }
}

/**
 * Helper class to store information about each thing.
 */
class ThingReference
{
   public var Version:int = 0;
   public var XMLData:XML = null;
   public var EntityCallback:Function = null;
   public var GroupCallback:Function = null;
   public var Identifier:String = "";
}