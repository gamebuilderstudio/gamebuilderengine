/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.entity
{
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.core.NameManager;
    import com.pblabs.engine.core.PBObject;
    import com.pblabs.engine.core.PBSet;
    import com.pblabs.engine.core.TemplateManager;
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.engine.debug.Profiler;
    import com.pblabs.engine.serialization.Serializer;
    import com.pblabs.engine.serialization.TypeUtility;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.utils.Dictionary;
    import flash.utils.getQualifiedClassName;
    
    /**
     * Default implementation of IEntity.
     * 
     * <p>Please use allocateEntity() to get at instances of Entity; this allows
     * us to pool Entities at a later date if needed and do other tricks. Please
     * program against IEntity, not Entity, to avoid dependencies.</p>
     */
    internal class Entity extends PBObject implements IEntity
    {        
        public function get deferring():Boolean
        {
            return _deferring;
        }
        
        public function set deferring(value:Boolean):void
        {
            if(_deferring == true && value == false)
            {
                // Resolve everything, and everything that that resolution triggers.
                var needReset:Boolean = _deferredComponents.length > 0;
                while(_deferredComponents.length)
                {
                    var pc:PendingComponent = _deferredComponents.shift() as PendingComponent;
                    pc.item.register(this, pc.name);
                }
                
                // Mark deferring as done.
                _deferring = false;
                
                // Fire off the reset.
                if(needReset)
                    doResetComponents();                
            }
            
            _deferring = value;
        }
        
        public function get eventDispatcher():IEventDispatcher
        {
            return _eventDispatcher;
        }
        
        public override function initialize(name:String = null, alias:String = null):void
        {            
            // Pass control up.
            super.initialize(name, alias);

            // Resolve any pending components.
            deferring = false;
        }
        
        public override function destroy():void
        {
            // Give listeners a chance to act before we start destroying stuff.
            if(_eventDispatcher.hasEventListener("EntityDestroyed"))
                _eventDispatcher.dispatchEvent(new Event("EntityDestroyed"));
            
            // Unregister our components.
            for each(var component:IEntityComponent in _components)
            {
                if(component.isRegistered)
                    component.unregister();    
            }
            
            // And remove their references from the dictionary.
            for (var name:String in _components)
                delete _components[name];

            // Get out of the NameManager and other general cleanup stuff.
            super.destroy();
        }
        
        /**
         * Serializes an entity. Pass in the current XML stream, and it automatically
         * adds itself to it.
         * @param	xml the <things> XML stream.
         */
        public function serialize(xml:XML):void
        {
            var entityXML:XML = <entity name={name} />;
            if(alias!=null)
                entityXML = <entity name={name} alias={alias} />;   
            
            for each (var component:IEntityComponent in _components)
            {        	
                var componentXML:XML = <component type={getQualifiedClassName(component).replace(/::/,".")} name={component.name} />;
                Serializer.instance.serialize(component, componentXML);
                entityXML.appendChild(componentXML);
            }

            xml.appendChild(entityXML);            
        }
        
        public function deserialize(xml:XML, registerComponents:Boolean = true):void
        {
            // Note what entity we're deserializing to the Serializer.
            Serializer.instance.setCurrentEntity(this);

            // Push the deferred state.
            var oldDefer:Boolean = deferring;
            deferring = true;
            
            // Process each component tag in the xml.
            for each (var componentXML:XML in xml.*)
            {
                // Error if it's an unexpected tag.
                if(componentXML.name().toString().toLowerCase() != "component")
                {
                    Logger.error(this, "deserialize", "Found unexpected tag '" + componentXML.name().toString() + "', only <component/> is valid, ignoring tag. Error in entity '" + name + "'.");
                    continue;
                }
                
                var componentName:String = componentXML.attribute("name");
                var componentClassName:String = componentXML.attribute("type");
                var component:IEntityComponent = null;
                
                if (componentClassName.length > 0)
                {
                    // If it specifies a type, instantiate a component and add it.
                    component = TypeUtility.instantiate(componentClassName) as IEntityComponent;
                    if (!component)
                    {
                        Logger.error(this, "deserialize", "Unable to instantiate component " + componentName + " of type " + componentClassName + " on entity '" + name + "'.");
                        continue;
                    }
                    
                    if (!addComponent(component, componentName))
                        continue;
                }
                else
                {
                    // Otherwise just get the existing one of that name.
                    component = lookupComponentByName(componentName);
                    if (!component)
                    {
                        Logger.error(this, "deserialize", "No type specified for the component " + componentName + " and the component doesn't exist on a parent template for entity '" + name + "'.");
                        continue;
                    }
                }
                
                // Deserialize the XML into the component.
                Serializer.instance.deserialize(component, componentXML);
            }
            
            // Deal with set membership.
            var setsAttr:String = xml.attribute("sets");
            if (setsAttr)
            {
                // The entity wants to be in some sets.
                var setNames:Array = setsAttr.split(",");
                if (setNames)
                {
                    // There's a valid-ish set string, let's loop through the entries
                    var thisName:String;
                    while (thisName = setNames.pop())
                    {
                        var pbset:PBSet = PBE.lookup(thisName) as PBSet;
                        if (!pbset) 
                        {
                            // Set doesn't exist, create a new one.
                            pbset = new PBSet();
                            pbset.initialize(thisName);
                            Logger.warn(this, "deserialize", "Auto-creating set '" + thisName + "'.");
                        }
                        pbset.add(this as PBObject);
                    }
                }
            }            
            
            // Restore deferred state.
            deferring = oldDefer;
        }
        
        public function addComponent(component:IEntityComponent, componentName:String):Boolean
        {
            // Add it to the dictionary.
            if (!doAddComponent(component, componentName))
                return false;

            // If we are deferring registration, put it on the list.
            if(deferring)
            {
                var p:PendingComponent = new PendingComponent();
                p.item = component;
                p.name = componentName;
                _deferredComponents.push(p);
                return true;
            }

            // We have to be careful w.r.t. adding components from another component.
            component.register(this, componentName);
            
            // Fire off the reset.
            doResetComponents();
            
            return true;
        }
        
        public function removeComponent(component:IEntityComponent):void
        {
            // Update the dictionary.
            if (!doRemoveComponent(component))
                return;

            // Deal with pending.
            if(component.isRegistered == false)
            {
                // Remove it from the deferred list.
                for(var i:int=0; i<_deferredComponents.length; i++)
                {
                    if((_deferredComponents[i] as PendingComponent).item != component)
                        continue;
                    
                    // TODO: Forcibly call register/unregister to ensure onAdd/onRemove semantics?
                    
                    _deferredComponents.splice(i, 1);
                    break;
                }

                return;
            }
            
            component.unregister();
            
            doResetComponents();
        }
        
        public function lookupComponentByType(componentType:Class):IEntityComponent
        {
            for each(var component:IEntityComponent in _components)
            {
                if (component is componentType)
                    return component;
            }
            
            return null;
        }
        
        public function lookupComponentsByType(componentType:Class):Array
        {
            var list:Array = new Array();
            
            for each(var component:IEntityComponent in _components)
            {
                if (component is componentType)
                    list.push(component);
            }
            
            return list;
        }
        
        public function lookupComponentByName(componentName:String):IEntityComponent
        {
            return _components[componentName];
        }
        
        public function doesPropertyExist(property:PropertyReference):Boolean
        {
            return findProperty(property, false, _tempPropertyInfo, true) != null;
        }
        
        public function getProperty(property:PropertyReference, defaultVal:* = null):*
        {
            // Look up the property.
            var info:PropertyInfo = findProperty(property, false, _tempPropertyInfo);
            var result:* = null;
            
            // Get value if any.
            if (info)
                result = info.getValue();
            else
                result = defaultVal; 
            
            // Clean up to avoid dangling references.
            _tempPropertyInfo.clear();
            
            return result;
        }
        
        public function setProperty(property:PropertyReference, value:*):void
        {
            // Look up and set.
            var info:PropertyInfo = findProperty(property, true, _tempPropertyInfo);
            if (info)
                info.setValue(value);
            
            // Clean up to avoid dangling references.
            _tempPropertyInfo.clear();
        }
        
        private function doAddComponent(component:IEntityComponent, componentName:String):Boolean
        {
            if (componentName == "")
            {
                Logger.warn(this, "AddComponent", "A component name was not specified. This might cause problems later.");
            }
            
            if (component.owner)
            {
                Logger.error(this, "AddComponent", "The component " + componentName + " already has an owner. (" + name + ")");
                return false;
            }
            
            if (_components[componentName])
            {
                Logger.error(this, "AddComponent", "A component with name " + componentName + " already exists on this entity (" + name + ").");
                return false;
            }
            
            component.owner = this;
            _components[componentName] = component;
            return true;
        }
        
        private function doRemoveComponent(component:IEntityComponent):Boolean
        {
            if (component.owner != this)
            {
                Logger.error(this, "AddComponent", "The component " + component.name + " is not owned by this entity. (" + name + ")");
                return false;
            }
            
            if (!_components[component.name])
            {
                Logger.error(this, "AddComponent", "The component " + component.name + " was not found on this entity. (" + name + ")");
                return false;
            }
            
            delete _components[component.name];
            return true;
        }
        
        /**
         * Call reset on all the registered components in this entity.
         */
        private function doResetComponents():void
        {
            var oldDefer:Boolean = _deferring;
            deferring = true;
            for each(var component:IEntityComponent in _components)
            {
                // Skip unregistered entities. 
                if(!component.isRegistered)
                    continue;
                
                // Reset it!
                component.reset();                
            }
            deferring = false;
        }
        
        private function findProperty(reference:PropertyReference, willSet:Boolean = false, providedPi:PropertyInfo = null, suppressErrors:Boolean = false):PropertyInfo
        {
            // TODO: we use appendChild but relookup the results, can we just use return value?
            
            // Early out if we got a null property reference.
            if (!reference || reference.property == null || reference.property == "")
                return null;
            
            Profiler.enter("Entity.findProperty");
            
            // Must have a propertyInfo to operate with.
            if(!providedPi)
                providedPi = new PropertyInfo();
            
            // Cached lookups apply only to components.
            if(reference.cachedLookup && reference.cachedLookup.length > 0)
            {
                var cl:Array = reference.cachedLookup;
                var cachedWalk:* = lookupComponentByName(cl[0]);
                if(!cachedWalk)
                {
                    if(!suppressErrors)
                        Logger.warn(this, "findProperty", "Could not resolve component named '" + cl[0] + "' for property '" + reference.property + "' with cached reference. " + Logger.getCallStack());
                    Profiler.exit("Entity.findProperty");
                    return null;
                }
                
                for(var i:int = 1; i<cl.length - 1; i++)
                {
                    cachedWalk = cachedWalk[cl[i]];
                    
                    if(cachedWalk == null)
                    {
                        if(!suppressErrors)
                            Logger.warn(this, "findProperty", "Could not resolve property '" + cl[i] + "' for property reference '" + reference.property + "' with cached reference"  + Logger.getCallStack());
                        Profiler.exit("Entity.findProperty");
                        return null;
                    }
                }
                
                var cachedPi:PropertyInfo = providedPi;
                cachedPi.propertyParent = cachedWalk;
                cachedPi.propertyName = (cl.length > 1) ? cl[cl.length-1] : null;
                Profiler.exit("Entity.findProperty");
                return cachedPi;
            }
            
            // Split up the property reference.      
            var propertyName:String = reference.property;
            var path:Array = propertyName.split(".");
            
            // Distinguish if it is a component reference (@), named object ref (#), or
            // an XML reference (!), and look up the first element in the path.
            var isTemplateXML:Boolean = false;
            var itemName:String = path[0];
            var curIdx:int = 1;
            var startChar:String = itemName.charAt(0);
            var curLookup:String = itemName.slice(1);
            var parentElem:*;
            if(startChar == "@")
            {
                // Component reference, look up the component by name.
                parentElem = lookupComponentByName(curLookup);
                if(!parentElem)
                {
                    Logger.warn(this, "findProperty", "Could not resolve component named '" + curLookup + "' for property '" + reference.property + "'");
                    Profiler.exit("Entity.findProperty");
                    return null;
                }
                
                // Cache the split out string.
                path[0] = curLookup;
                reference.cachedLookup = path;
            }
            else if(startChar == "#")
            {
                // Named object reference. Look up the entity in the NameManager.
                parentElem = PBE.nameManager.lookup(curLookup);
                if(!parentElem)
                {
                    Logger.warn(this, "findProperty", "Could not resolve named object named '" + curLookup + "' for property '" + reference.property + "'");
                    Profiler.exit("Entity.findProperty");
                    return null;
                }
                
                // Get the component on it.
                curIdx++;
                curLookup = path[1];
                var comLookup:IEntityComponent = (parentElem as IEntity).lookupComponentByName(curLookup);
                if(!comLookup)
                {
                    Logger.warn(this, "findProperty", "Could not find component '" + curLookup + "' on named entity '" + (parentElem as IEntity).name + "' for property '" + reference.property + "'");
                    Profiler.exit("Entity.findProperty");
                    return null;
                }
                parentElem = comLookup;
            }
            else if(startChar == "!")
            {
                // XML reference. Look it up inside the TemplateManager. We only support
                // templates and entities - no groups.
                parentElem = PBE.templateManager.getXML(curLookup, "template", "entity");
                if(!parentElem)
                {
                    Logger.warn(this, "findProperty", "Could not find XML named '" + curLookup + "' for property '" + reference.property + "'");
                    Profiler.exit("Entity.findProperty");
                    return null;
                }
                
                // Try to find the specified component.
                curIdx++;
                var nextElem:* = null;
                for each(var cTag:* in parentElem.*)
                {
                    if(cTag.@name == path[1])
                    {
                        nextElem = cTag;
                        break;
                    }
                }
                
                // Create it if appropriate.
                if(!nextElem && willSet)
                {
                    // Create component tag.
                    (parentElem as XML).appendChild(<component name={path[1]}/>);
                    
                    // Look it up again.
                    for each(cTag in parentElem.*)
                    {
                        if(cTag.@name == path[1])
                        {
                            nextElem = cTag;
                            break;
                        }
                    }
                }
                
                // Error if we don't have it!
                if(!nextElem)
                {
                    Logger.warn(this, "findProperty", "Could not find component '" + path[1] + "' in XML template '" + path[0].slice(1) + "' for property '" + reference.property + "'");
                    Profiler.exit("Entity.findProperty");
                    return null;
                }
                
                // Get ready to search the rest.
                parentElem = nextElem;
                
                // Indicate we are dealing with xml.
                isTemplateXML = true;
            }
            else
            {
                Logger.warn(this, "findProperty", "Got a property path that doesn't start with !, #, or @. Started with '" + startChar + "' for property '" + reference.property + "'");
                Profiler.exit("Entity.findProperty");
                return null;
            }
            
            // Make sure we have a field to look up.
            if(curIdx < path.length)
                curLookup = path[curIdx++] as String;
            else
                curLookup = null;
            
            // Do the remainder of the look up.
            while(curIdx < path.length && parentElem)
            {
                // Try the next element in the path.
                var oldParentElem:* = parentElem;
                try
                {
                    if(parentElem is XML || parentElem is XMLList)
                        parentElem = parentElem.child(curLookup);
                    else
                        parentElem = parentElem[curLookup];
                }
                catch(e:Error)
                {
                    parentElem = null;
                }
                
                // Several different possibilities that indicate we failed to advance.
                var gotEmpty:Boolean = false;
                if(parentElem == undefined) gotEmpty = true;
                if(parentElem == null) gotEmpty = true;
                if(parentElem is XMLList && parentElem.length() == 0) gotEmpty = true;
                
                // If we're going to set and it's XML, create the field.
                if(willSet && isTemplateXML && gotEmpty && oldParentElem)
                {
                    oldParentElem.appendChild(<{curLookup}/>);
                    parentElem = oldParentElem.child(curLookup);
                    gotEmpty = false;
                }
                
                if(gotEmpty)
                {
                    Logger.warn(this, "findProperty", "Could not resolve property '" + curLookup + "' for property reference '" + reference.property + "'");
                    Profiler.exit("Entity.findProperty");
                    return null;
                }
                
                // Advance to next element in the path.
                curLookup = path[curIdx++] as String;
            }
            
            // Did we end up with a match?
            if(parentElem)
            {
                var pi:PropertyInfo = providedPi;
                pi.propertyParent = parentElem;
                pi.propertyName = curLookup;
                Profiler.exit("Entity.findProperty");
                return pi;
            }
            
            Profiler.exit("Entity.findProperty");
            return null;
        }
        
        private var _deferring:Boolean = true;
        
        protected var _components:Dictionary = new Dictionary();
        protected var _tempPropertyInfo:PropertyInfo = new PropertyInfo();
        protected var _deferredComponents:Array = new Array();
        protected var _eventDispatcher:EventDispatcher = new EventDispatcher();
    }
}

import com.pblabs.engine.entity.IEntityComponent;

final class PendingComponent
{
    public var item:IEntityComponent;
    public var name:String;
}
