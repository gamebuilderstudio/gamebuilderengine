/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Engine.Entity
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

import PBLabs.Engine.Entity.IEntity;
import PBLabs.Engine.Entity.IEntityComponent;
import PBLabs.Engine.Entity.PropertyReference;
import PBLabs.Engine.Core.NameManager;
import PBLabs.Engine.Debug.Logger;
import PBLabs.Engine.Serialization.Serializer;
import PBLabs.Engine.Serialization.TypeUtility;

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
   
   public function Initialize(name:String):void
   {
      _name = name;
      if ((_name == null) || (_name == ""))
         return;
      
      NameManager.Instance.AddEntity(this, _name);
   }
   
   public function Destroy():void
   {
      NameManager.Instance.RemoveEntity(this);
      _name = null;
      
      for each(var component:IEntityComponent in _components)
         component.Unregister();
      
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
      for each (var componentXML:XML in xml.*)
      {
         var componentName:String = componentXML.attribute("name");
         var componentClassName:String = componentXML.attribute("type");
         var component:IEntityComponent = null;
         
         if (componentClassName.length > 0)
         {
            component = TypeUtility.Instantiate(componentClassName) as IEntityComponent;
            if (component == null)
            {
               Logger.PrintError(this, "Deserialize", "Unable to instantiate component " + componentName + " of type " + componentClassName + ".");
               continue;
            }
            
            if (!_AddComponent(component, componentName))
               continue;
         }
         else
         {
            component = LookupComponentByName(componentName);
            if (component == null)
            {
               Logger.PrintError(this, "Deserialize", "No type specified for the component " + componentName + " and the component doesn't exist on a parent template.");
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
      return _FindProperty(property) != null;
   }
   
   public function GetProperty(property:PropertyReference):*
   {
      var info:PropertyInfo = _FindProperty(property);
      if (info != null)
         return info.GetValue();
      
      return null;
   }
   
   public function SetProperty(property:PropertyReference, value:*):void
   {
      var info:PropertyInfo = _FindProperty(property);
      if (info != null)
         info.SetValue(value);
   }
   
   private function _AddComponent(component:IEntityComponent, componentName:String):Boolean
   {
      if (component.Owner != null)
      {
         Logger.PrintError(this, "AddComponent", "The component " + componentName + " already has an owner.");
         return false;
      }
      
      if (_components[componentName] != null)
      {
         Logger.PrintError(this, "AddComponent", "A component with name " + componentName + " already exists on this entity.");
         return false;
      }
      
      _components[componentName] = component;
      return true;
   }
   
   private function _RemoveComponent(component:IEntityComponent):Boolean
   {
      if (component.Owner != this)
      {
         Logger.PrintError(this, "AddComponent", "The component " + component.Name + " is not owned by this entity.");
         return false;
      }
      
      if (_components[component.Name] == null)
      {
         Logger.PrintError(this, "AddComponent", "The component " + component.Name + " was not found on this entity.");
         return false;
      }
      
      delete _components[component.Name];
      return true;
   }
   
   private function _RegisterComponents():void
   {
      for (var name:String in _components)
         _components[name].Register(this, name);
   }
   
   private function _ResetComponents():void
   {
      for each(var component:IEntityComponent in _components)
         component.Reset();
   }

   private function _FindProperty(reference:PropertyReference):PropertyInfo
   {
      if ((reference == null) || (reference.Property == null) || (reference.Property == ""))
         return null;
      
      var propertyName:String = reference.Property;
      var path:Array = propertyName.split(".");
      if (path.length < 2)
      {
         Logger.PrintWarning(this, "_FindProperty", "A property path must consist of a component name followed by at least one field name.");
         return null;
      }
      
      var componentName:String = path[0];
      if (componentName.charAt(0) != "@")
      {
         Logger.PrintWarning(this, "_FindProperty", "The first part of a property path must be '@' followed by a component name.");
         return null;
      }
      
      componentName = componentName.slice(1);
      var parentObject:* = LookupComponentByName(componentName);
      if (parentObject == null)
      {
         Logger.PrintWarning(this, "_FindProperty", "A component named " + componentName + " was not found on this entity.");
         return null;
      }
      
      var fieldName:String = path[1];
      
      for (var i:int = 2; i < path.length; i++)
      {
         try
         {
            parentObject = parentObject[fieldName];         
         }
         catch(e:Error)
         {
            parentObject = null;
         }
         
         fieldName = path[i];
         
         if (parentObject == null)
         {
            Logger.PrintWarning(this, "_FindProperty", "The path " + propertyName + " could not be resolved." + fieldName + " is not a valid field.");
            return null;
         }
      }
      
      if (!parentObject.hasOwnProperty(fieldName))
      {
         Logger.PrintWarning(this, "_FindProperty", "The path " + propertyName + " could not be resolved." + fieldName + " is not a valid field.");
         return null;
      }
      
      var info:PropertyInfo = new PropertyInfo();
      info.PropertyParent = parentObject;
      info.PropertyName = fieldName;
      return info;            
   }
   
   private var _name:String = null;
   private var _components:Dictionary = new Dictionary();
}

class PropertyInfo
{
   public var PropertyParent:Object = null;
   public var PropertyName:String = null;
   
   public function GetValue():*
   {
      return PropertyParent[PropertyName];
   }
   
   public function SetValue(value:*):void
   {
      PropertyParent[PropertyName] = value;
   }
}
