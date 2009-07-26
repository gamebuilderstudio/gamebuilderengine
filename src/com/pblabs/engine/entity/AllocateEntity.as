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
   /**
    * Allocates an instance of the hidden Entity class. This should be
    * used anytime an IEntity object needs to be created. Encapsulating
    * the Entity class forces code to use IEntity rather than Entity when
    * dealing with entity references. This will ensure that code is future
    * proof as well as allow the Entity class to be pooled in the future.
    * 
    * @return A new IEntity.
    */
   public function AllocateEntity():IEntity
   {
      return new Entity();
   }
}

import com.pblabs.engine.entity.IEntity;
import com.pblabs.engine.entity.IEntityComponent;
import com.pblabs.engine.entity.PropertyReference;
import com.pblabs.engine.core.NameManager;
import com.pblabs.engine.core.TemplateManager;
import com.pblabs.engine.debug.Logger;
import com.pblabs.engine.debug.Profiler;
import com.pblabs.engine.serialization.Serializer;
import com.pblabs.engine.serialization.TypeUtility;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.utils.Dictionary;

class Entity extends EventDispatcher implements IEntity
{
   public function get Name():String
   {
      return _name;
   }
   
   public function get EventDispatcher():IEventDispatcher
   {
      return this as IEventDispatcher;
   }
   
   public function Initialize(name:String, alias:String = null):void
   {
      _name = name;
      if (_name == null || _name == "")
         return;
      
      _alias = alias;
         
      NameManager.Instance.AddEntity(this, _name);
      if(_alias)
         NameManager.Instance.AddEntity(this, _alias);
   }
   
   public function Destroy():void
   {
      // Give listeners a chance to act before we start destroying stuff.
      dispatchEvent(new Event("EntityDestroyed"));
      
      // Get out of the NameManager.
      NameManager.Instance.RemoveEntity(this);
      _name = null;
      
      // Unregister our components.
      for each(var component:IEntityComponent in _components)
         component.Unregister();
      
      // And remove their references from the dictionary.
      for (var name:String in _components)
         delete _components[name];
   }
   
   public function Serialize(xml:XML):void
   {
      for each (var component:IEntityComponent in _components)
      {
         var componentXML:XML = new XML(<Component/>);
         Serializer.Instance.Serialize(component, componentXML);
         xml.appendChild(componentXML);
      }
   }
   
   public function Deserialize(xml:XML, registerComponents:Boolean = true):void
   {
      // Note what entity we're deserializing to the serializer.
      Serializer.Instance.SetCurrentEntity(this);
      
      for each (var componentXML:XML in xml.*)
      {
         // Error if it's an unexpected tag.
         if(componentXML.name().toString().toLowerCase() != "component")
         {
            Logger.PrintError(this, "Deserialize", "Found unexpected tag '" + componentXML.name().toString() + "', only <component/> is valid, ignoring tag. Error in entity '" + Name + "'.");
            continue;
         }
         
         var componentName:String = componentXML.attribute("name");
         var componentClassName:String = componentXML.attribute("type");
         var component:IEntityComponent = null;
         
         if (componentClassName.length > 0)
         {
            component = TypeUtility.Instantiate(componentClassName) as IEntityComponent;
            if (!component)
            {
               Logger.PrintError(this, "Deserialize", "Unable to instantiate component " + componentName + " of type " + componentClassName + " on entity '" + Name + "'.");
               continue;
            }
            
            if (!_AddComponent(component, componentName))
               continue;
         }
         else
         {
            component = LookupComponentByName(componentName);
            if (!component)
            {
               Logger.PrintError(this, "Deserialize", "No type specified for the component " + componentName + " and the component doesn't exist on a parent template for entity '" + Name + "'.");
               continue;
            }
         }
         
         Serializer.Instance.Deserialize(component, componentXML);
      }
      
      if (registerComponents)
      {
         _RegisterComponents();
         _ResetComponents();
      }
   }
   
   public function AddComponent(component:IEntityComponent, componentName:String):void
   {
      if (!_AddComponent(component, componentName))
         return;
      
      component.Register(this, componentName);
      _ResetComponents();
   }
   
   public function RemoveComponent(component:IEntityComponent):void
   {
      if (!_RemoveComponent(component))
         return;
      
      component.Unregister();
      _ResetComponents();
   }
   
   public function LookupComponentByType(componentType:Class):IEntityComponent
   {
      for each(var component:IEntityComponent in _components)
      {
         if (component is componentType)
            return component;
      }
      
      return null;
   }
   
   public function LookupComponentsByType(componentType:Class):Array
   {
      var list:Array = new Array();
      
      for each(var component:IEntityComponent in _components)
      {
         if (component is componentType)
            list.push(component);
      }
      
      return list;
   }
   
   public function LookupComponentByName(componentName:String):IEntityComponent
   {
      return _components[componentName];
   }
   
   public function DoesPropertyExist(property:PropertyReference):Boolean
   {
      return _FindProperty(property, false, _tempPropertyInfo, true) != null;
   }
   
   public function GetProperty(property:PropertyReference):*
   {
      // Look up the property.
      var info:PropertyInfo = _FindProperty(property, false, _tempPropertyInfo);
      var result:* = null;
      
      // Get value if any.
      if (info)
         result = info.GetValue();

      // Clean up to avoid dangling references.
      _tempPropertyInfo.Clear();
      
      return result;
   }
   
   public function SetProperty(property:PropertyReference, value:*):void
   {
      // Look up and set.
      var info:PropertyInfo = _FindProperty(property, true, _tempPropertyInfo);
      if (info)
         info.SetValue(value);

      // Clean up to avoid dangling references.
      _tempPropertyInfo.Clear();
   }
   
   private function _AddComponent(component:IEntityComponent, componentName:String):Boolean
   {
      if (component.Owner)
      {
         Logger.PrintError(this, "AddComponent", "The component " + componentName + " already has an owner. (" + Name + ")");
         return false;
      }
      
      if (_components[componentName])
      {
         Logger.PrintError(this, "AddComponent", "A component with name " + componentName + " already exists on this entity (" + Name + ").");
         return false;
      }
      
      _components[componentName] = component;
      return true;
   }
   
   private function _RemoveComponent(component:IEntityComponent):Boolean
   {
      if (component.Owner != this)
      {
         Logger.PrintError(this, "AddComponent", "The component " + component.Name + " is not owned by this entity. (" + Name + ")");
         return false;
      }
      
      if (!_components[component.Name])
      {
         Logger.PrintError(this, "AddComponent", "The component " + component.Name + " was not found on this entity. (" + Name + ")");
         return false;
      }
      
      delete _components[component.Name];
      return true;
   }
   
   /**
    * Register any unregistered components on this entity. Useful when you are
    * deferring registration (for instance due to template processing).
    */
   private function _RegisterComponents():void
   {
      for (var name:String in _components)
      {
         // Skip ones we have already registered.
         if(_components[name].IsRegistered)
            continue;
         
         _components[name].Register(this, name);
      }
   }
   
   private function _ResetComponents():void
   {
      for each(var component:IEntityComponent in _components)
         component.Reset();
   }

   private function _FindProperty(reference:PropertyReference, willSet:Boolean = false, providedPi:PropertyInfo = null, suppressErrors:Boolean = false):PropertyInfo
   {
      // TODO: we use appendChild but relookup the results, can we just use return value?
      
      // Early out if we got a null property reference.
      if (!reference || reference.Property == null || reference.Property == "")
         return null;

      Profiler.Enter("Entity._FindProperty");
      
      // Must have a propertyInfo to operate with.
      if(!providedPi)
         providedPi = new PropertyInfo();
      
      // Cached lookups apply only to components.
      if(reference.CachedLookup && reference.CachedLookup.length > 0)
      {
         var cl:Array = reference.CachedLookup;
         var cachedWalk:* = LookupComponentByName(cl[0]);
         if(!cachedWalk)
         {
            if(!suppressErrors)
               Logger.PrintWarning(this, "_FindProperty", "Could not resolve component named '" + cl[0] + "' for property '" + reference.Property + "' with cached reference. " + Logger.GetCallStack());
            Profiler.Exit("Entity._FindProperty");
            return null;
         }
         
         for(var i:int = 1; i<cl.length - 1; i++)
         {
            cachedWalk = cachedWalk[cl[i]];
            if(!cachedWalk)
            {
               if(!suppressErrors)
                  Logger.PrintWarning(this, "_FindProperty", "Could not resolve property '" + cl[i] + "' for property reference '" + reference.Property + "' with cached reference"  + Logger.GetCallStack());
               Profiler.Exit("Entity._FindProperty");
               return null;
            }
         }
         
         var cachedPi:PropertyInfo = providedPi;
         cachedPi.PropertyParent = cachedWalk;
         cachedPi.PropertyName = cl[cl.length-1];
         Profiler.Exit("Entity._FindProperty");
         return cachedPi;
      }
      
      // Split up the property reference.      
      var propertyName:String = reference.Property;
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
         parentElem = LookupComponentByName(curLookup);
         if(!parentElem)
         {
            Logger.PrintWarning(this, "_FindProperty", "Could not resolve component named '" + curLookup + "' for property '" + reference.Property + "'");
            Profiler.Exit("Entity._FindProperty");
            return null;
         }
         
         // Cache the split out string.
         path[0] = curLookup;
         reference.CachedLookup = path;
      }
      else if(startChar == "#")
      {
         // Named object reference. Look up the entity in the NameManager.
         parentElem = NameManager.Instance.Lookup(curLookup);
         if(!parentElem)
         {
            Logger.PrintWarning(this, "_FindProperty", "Could not resolve named object named '" + curLookup + "' for property '" + reference.Property + "'");
            Profiler.Exit("Entity._FindProperty");
            return null;
         }
         
         // Get the component on it.
         curIdx++;
         curLookup = path[1];
         var comLookup:IEntityComponent = (parentElem as IEntity).LookupComponentByName(curLookup);
         if(!comLookup)
         {
            Logger.PrintWarning(this, "_FindProperty", "Could not find component '" + curLookup + "' on named entity '" + (parentElem as IEntity).Name + "' for property '" + reference.Property + "'");
            Profiler.Exit("Entity._FindProperty");
            return null;
         }
         parentElem = comLookup;
      }
      else if(startChar == "!")
      {
         // XML reference. Look it up inside the TemplateManager. We only support
         // templates and entities - no groups.
         parentElem = TemplateManager.Instance.GetXML(curLookup, "template", "entity");
         if(!parentElem)
         {
            Logger.PrintWarning(this, "_FindProperty", "Could not find XML named '" + curLookup + "' for property '" + reference.Property + "'");
            Profiler.Exit("Entity._FindProperty");
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
            Logger.PrintWarning(this, "_FindProperty", "Could not find component '" + path[1] + "' in XML template '" + path[0].slice(1) + "' for property '" + reference.Property + "'");
            Profiler.Exit("Entity._FindProperty");
            return null;
         }
         
         // Get ready to search the rest.
         parentElem = nextElem;
         
         // Indicate we are dealing with xml.
         isTemplateXML = true;
      }
      else
      {
         Logger.PrintWarning(this, "_FindProperty", "Got a property path that doesn't start with !, #, or @. Started with '" + startChar + "' for property '" + reference.Property + "'");
         Profiler.Exit("Entity._FindProperty");
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
            Logger.PrintWarning(this, "_FindProperty", "Could not resolve property '" + curLookup + "' for property reference '" + reference.Property + "'");
            Profiler.Exit("Entity._FindProperty");
            return null;
         }
         
         // Advance to next element in the path.
         curLookup = path[curIdx++] as String;
      }
      
      // Did we end up with a match?
      if(parentElem)
      {
         var pi:PropertyInfo = providedPi;
         pi.PropertyParent = parentElem;
         pi.PropertyName = curLookup;
         Profiler.Exit("Entity._FindProperty");
         return pi;
      }
      
      Profiler.Exit("Entity._FindProperty");
      return null;
   }
   
   private var _name:String = null;
   private var _alias:String = null;
   private var _components:Dictionary = new Dictionary();
   private var _tempPropertyInfo:PropertyInfo = new PropertyInfo();
}

class PropertyInfo
{
   public var PropertyParent:Object = null;
   public var PropertyName:String = null;
   
   public function GetValue():*
   {
      try
      {
         return PropertyParent[PropertyName];
      }
      catch(e:Error)
      {
         return null;
      }
   }
   
   public function SetValue(value:*):void
   {
      PropertyParent[PropertyName] = value;
   }
   
   public function Clear():void
   {
      PropertyParent = null;
      PropertyName = null;
   }
}
