/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Engine.Serialization
{
   import PBLabs.Engine.Debug.Logger;
   import PBLabs.Engine.Entity.*;
   
   import flash.utils.Dictionary;
   
   /**
    * Singleton class for serializing and deserializing objects. This class 
    * implements a default serialization behavior based on the format described
    * in the XMLFormat reference. This default behavior can be replaced on a class
    * by class basis by implementing the ISerializable interface.
    * 
    * @see ISerializable
    */
   public class Serializer
   {
      /**
       * Gets the singleton instance of the serializer class.
       */
      public static function get Instance():Serializer
      {
         if (_instance == null)
            _instance = new Serializer();
         
         return _instance;
      }
      
      private static var _instance:Serializer = null;
      
      public function Serializer()
      {
         // Initialize our default serializers. Note "special" cases get a double
         // colon so there can be no overlap w/ any real type.
         _deserializers["::DefaultSimple"] = _DeserializeSimple;
         _deserializers["::DefaultComplex"] = _DeserializeComplex;
         _deserializers["Boolean"] = _DeserializeBoolean;
         _deserializers["Array"] = _DeserializeDictionary;
         _deserializers["flash.utils::Dictionary"] = _DeserializeDictionary;
         
         _serializers["::DefaultSimple"] = _SerializeSimple;
         _serializers["::DefaultComplex"] = _SerializeComplex;
         _serializers["Boolean"] = _SerializeBoolean;
         
         // Do a quick sanity check to make sure we are getting metadata.
         var tmd:TestForMetadata = new TestForMetadata();
         if(TypeUtility.GetTypeHint(tmd, "SomeArray") != "Number")
            throw new Error("Metadata is not included in this build of the engine, so serialization will not work!\nYou probably need to regenerate your projects with the latest version of the engine manager, and recompile.\nMake sure that metadata is enabled in your compiler settings if you are not using the engine manager.");
      }
      
      /**
       * Serializes an object to XML. This is currently not implemented.
       * 
       * @param object The object to serialize. If this object implements ISerializable,
       * its Serialize method will be called to do the serialization, otherwise the default
       * behavior will be used.
       * 
       * @return The xml describing the specified object.
       * 
       * @see ISerializable
       */
      public function Serialize(object:*, xml:XML):void
      {
         if (object is ISerializable)
         {
            (object as ISerializable).Serialize(xml);
         }
         else if (object is IEntity)
         {
            _currentEntity = object as IEntity;
            _currentEntity.Serialize(xml);
         }
         else
         {
            // Normal case - determine type and call the right serializer.
            var typeName:String = TypeUtility.GetObjectClassName(object);
            if (_serializers[typeName] == null)
               typeName = _IsSimpleType(object) ? "::DefaultSimple" : "::DefaultComplex";
            
            _serializers[typeName](object, xml);
         }
      }
      
      /**
       * Deserializes an object from an xml description.
       * 
       * @param object The object on which the xml description will be applied.
       * @param xml The xml to deserialize from.
       * @param typeHint For an array, dictionary, or dynamic class, a type hint can
       *                be specified as to what its children should be. Optional.
       * 
       * @return A reference to the deserialized object. This is always the same as
       * the object parameter, with the exception of types that are passed by value.
       * Code that calls this method should always use the return value rather than
       * the passed in value for this reason.
       */
      public function Deserialize(object:*, xml:XML, typeHint:String=null):*
      {
         // Dispatch our special cases - entities and ISerializables.
         if (object is ISerializable)
         {
            return (object as ISerializable).Deserialize(xml);
         }
         else if (object is IEntity)
         {
            _currentEntity = object as IEntity;
            _currentEntity.Deserialize(xml, true);
            ResolveReferences();
            return object as IEntity;
         }
         
         // Normal case - determine type and call the right serializer.
         var typeName:String = TypeUtility.GetObjectClassName(object);
         if (_deserializers[typeName] == null)
            typeName = xml.hasSimpleContent() ? "::DefaultSimple" : "::DefaultComplex";
         
         return _deserializers[typeName](object, xml, typeHint);
      }
      
      /**
       * Set the entity relative to which current serialization work is happening. Mostly for internal use.
       */
      public function SetCurrentEntity(e:IEntity):void
      {
         _currentEntity = e;
      }
      
      /**
       * Clear the entity relative to which current serialization work is happening. Mostly for internal use.
       */
      public function ClearCurrentEntity():void
      {
         _currentEntity = null;
      }
      
      /**
       * Not all references are resolved immediately. In order to minimize spam,
       * we only report "dangling references" at certain times. This method 
       * triggers such a report.
       */
      public function ReportMissingReferences():void
      {
         for (var i:int = 0; i < _deferredReferences.length; i++)
         {
            var reference:ReferenceNote = _deferredReferences[i];
            reference.ReportMissing();
         }
      }
      
      private function _IsSimple(xml:XML, typeName:String):Boolean
      {
         // Complex content is assumed if there are child nodes in the xml, or the xml text is
         // an empty string, unless the type is a string. This is because any simple type that
         // is not a string has to have a value. Otherwise, it must be a class that doesn't have
         // its children specified.
         if (typeName == "String")
            return true;
         
         if (xml.hasComplexContent())
            return false;
         
         if (xml.toString() == "")
            return false;
         
         return true;
      }
      
      private function _IsSimpleType(object:*):Boolean
      {
         var typeName:String = TypeUtility.GetObjectClassName(object);
         if ((typeName == "String") || (typeName == "int") || (typeName == "Number") || (typeName == "uint") || (typeName == "Boolean"))
            return true;
         
         return false;
      }
      
      private function _DeserializeSimple(object:*, xml:XML, typeHint:String):*
      {
         if (xml.toString() == "")
            return object;
         
         return xml.toString();
      }
      
      private function _SerializeSimple(object:*, xml:XML):void
      {
         xml.appendChild(object.toString());
      }
      
      private function _DeserializeComplex(object:*, xml:XML, typeHint:String):*
      {
         var isDynamic:Boolean = (object is Array) || (object is Dictionary) || (TypeUtility.IsDynamic(object));
         
         for each (var fieldXML:XML in xml.*)
         {
            // Figure out the field we're setting, and make sure it is present.
            var fieldName:String = fieldXML.name().toString();
            if (!object.hasOwnProperty(fieldName) && !isDynamic)
            {
               Logger.PrintWarning(object, "Deserialize", "The field " + fieldName + " does not exist on the class " + TypeUtility.GetObjectClassName(object) + ".");
               continue;
            }
            
            // Determine the type.
            var typeName:String = fieldXML.attribute("type");
            if (typeName.length < 1)
               typeName = TypeUtility.GetFieldType(object, fieldName);
            if (isDynamic && typeName == null)
               typeName = "String";
            
            // Deserialize into the child.
            if (!_GetChildReference(object, fieldName, fieldXML) && !_GetResourceObject(object, fieldName, fieldXML))
            {
               var child:* = _GetChildObject(object, fieldName, typeName);
               if (child != null)
               {
                  // Deal with typehints.
                  var childTypeHint:String = TypeUtility.GetTypeHint(object, fieldName);
                  child = Deserialize(child, fieldXML, childTypeHint);
               }
               
               // Assign the new value.
               try
               {
                  object[fieldName] = child;
               }
               catch(e:Error)
               {
                  Logger.PrintError(object, "Deserialize", "The field " + fieldName + " could not be set to '" + child + "' due to:" + e.toString());
               }
            }
         }
         
         return object;
      }
      
      private function _SerializeComplex(object:*, xml:XML):void
      {
         var classDescription:XML = TypeUtility.GetTypeDescription(object);
         for each (var property:XML in classDescription.child("accessor"))
         {
            if (property.@access == "readwrite")
            {
               var propertyName:String = property.@name;
               var propertyXML:XML = <{propertyName}/>
               Serialize(object[propertyName], propertyXML);
               xml.appendChild(propertyXML);
            }
         }
         
         for each (var field:XML in classDescription.child("variable"))
         {
            var fieldName:String = field.@name;
            var fieldXML:XML = <{fieldName}/>
            Serialize(object[fieldName], fieldXML);
            xml.appendChild(fieldXML);
         }
      }
      
      private function _DeserializeBoolean(object:*, xml:XML, typeHint:String):*
      {
         return (xml.toString() == "true")
      }
      
      private function _SerializeBoolean(object:*, xml:XML):void
      {
         if (object == true)
            xml.appendChild("true");
         else
            xml.appendChild("false");
      }
      
      private function _DeserializeDictionary(object:*, xml:XML, typeHint:String):*
      {
         for each (var childXML:XML in xml.*)
         {
            // Where are we assigning this item?
            var key:String = childXML.name().toString();

            // Deal with escaping numbers and the "add to end" behavior.
            if (key.charAt(0) == "_")
               key = key.slice(1);
            
            // Might be invalid...
            if ((key.length < 1) && !(object is Array))
            {
               Logger.PrintError(object, "Deserialize", "Cannot add a value to a dictionary without a key.");
               continue;
            }
            
            // Infer the type.
            var typeName:String = childXML.attribute("type");
            if (typeName.length < 1)
               typeName = xml.attribute("childType");
            
            if (typeName == null || typeName == "")
               typeName = typeHint ? typeHint : "String";
            
            // Deserialize the value.
            if (!_GetChildReference(object, key, childXML) && !_GetResourceObject(object, key, childXML, typeHint))
            {
               var value:* = _GetChildObject(object, key, typeName);
               if (value != null)
                  value = Deserialize(value, childXML);
               
               // Assign, either to key or to end of array.
               if (key.length > 0)
                  object[key] = value;
               else
                  (object as Array).push(value);
            }
         }
         
         return object;
      }
      
      private function _GetChildReference(object:*, fieldName:String, xml:XML):Boolean
      {
         var nameReference:String = xml.attribute("nameReference");
         var componentReference:String = xml.attribute("componentReference");
         var componentName:String = xml.attribute("componentName");
         var objectReference:String = xml.attribute("objectReference");
         
         if ((nameReference != "") || (componentReference != "") || (componentName != "") || (objectReference != ""))
         {
            var reference:ReferenceNote = new ReferenceNote();
            reference.Owner = object;
            reference.FieldName = fieldName;
            reference.NameReference = nameReference;
            reference.ComponentReference = componentReference;
            reference.ComponentName = componentName
            reference.ObjectReference = objectReference;
            reference.CurrentEntity = _currentEntity;
            
            if (!reference.Resolve())
               _deferredReferences.push(reference);
            
            return true;
         }
         
         return false;
      }
      
      /**
       * Find or instantiate the value that should go in a field.
       */
      private function _GetChildObject(object:*, fieldName:String, typeName:String):*
      {
         var childObject:*;
         
         try
         {
            childObject = object[fieldName]; 
         } 
         catch(e:Error)
         {
         }
         
         if (childObject == null)
            childObject = TypeUtility.Instantiate(typeName);
         
         if (childObject == null)
         {
            Logger.PrintError(object, "Deserialize", "Unable to create type " + typeName + " for the field " + fieldName + ".");
            return null;
         }
         
         return childObject;
      }
      
      private function _GetResourceObject(object:*, fieldName:String, xml:XML, typeHint:String = null):Boolean
      {
         var filename:String = xml.attribute("filename");
         if (filename == "")
            return false;
            
         var type:Class = null;
         if(typeHint)
            type = TypeUtility.GetClassFromName(typeHint);
         else
            type = TypeUtility.GetClassFromName(TypeUtility.GetFieldType(object, fieldName));
         
         var resource:ResourceNote = new ResourceNote();
         resource.Owner = object;
         resource.FieldName = fieldName;
         resource.Load(filename, type);
         
         // we have to hang on to these so they don't get garbage collected
         _resources[filename] = resource;
         return true;
      }
      
      // internal doesn't work here for some reason. It's just being referenced in the ResourceNote support class
      public function _RemoveResource(filename:String):void
      {
         _resources[filename] = null;
         delete _resources[filename];
      }
      
      public function ResolveReferences():void
      {
         for (var i:int = 0; i < _deferredReferences.length; i++)
         {
            var reference:ReferenceNote = _deferredReferences[i];
            if (reference.Resolve())
            {
               _deferredReferences.splice(i, 1);
               i--;
            }
         }
      }
      
      private var _currentEntity:IEntity = null;
      private var _serializers:Dictionary = new Dictionary();
      private var _deserializers:Dictionary = new Dictionary();
      private var _deferredReferences:Array = new Array();
      private var _resources:Dictionary = new Dictionary();
   }
}

import PBLabs.Engine.Entity.IEntity;
import PBLabs.Engine.Entity.IEntityComponent;
import PBLabs.Engine.Debug.Logger;
import PBLabs.Engine.Core.NameManager;
import PBLabs.Engine.Core.TemplateManager;
import PBLabs.Engine.Serialization.TypeUtility;
import PBLabs.Engine.Resource.Resource;
import PBLabs.Engine.Resource.ResourceManager;
import PBLabs.Engine.Serialization.Serializer;

internal class ResourceNote
{
   public var Owner:* = null;
   public var FieldName:String = null;
   
   public function Load(filename:String, type:Class):void
   {
      ResourceManager.Instance.Load(filename, type, _OnLoaded, _OnFailed);
   }
   
   public function _OnLoaded(resource:Resource):void
   {
      Owner[FieldName] = resource;
      Serializer.Instance._RemoveResource(resource.Filename);
   }
   
   public function _OnFailed(resource:Resource):void
   {
      Logger.PrintError(Owner, "set " + FieldName, "No resource was found with filename " + resource.Filename + ".");
      Serializer.Instance._RemoveResource(resource.Filename);
   }
}

internal class ReferenceNote
{
   public var Owner:* = null;
   public var FieldName:String = null;
   public var NameReference:String = null;
   public var ComponentReference:String = null;
   public var ComponentName:String = null;
   public var ObjectReference:String = null;
   public var CurrentEntity:IEntity = null;
   public var ReportedMissing:Boolean = false;
   
   public function Resolve():Boolean
   {
      // Look up by name.
      if (NameReference != "")
      {
         var namedObject:IEntity = NameManager.Instance.Lookup(NameReference);
         if (namedObject == null)
            return false;
         
         Owner[FieldName] = namedObject;
         _ReportSuccess();
         return true;
      }
      
      // Look up a component on a named object by name (first) or type (second).
      if (ComponentReference != "")
      {
         var componentObject:IEntity = NameManager.Instance.Lookup(ComponentReference);
         if (componentObject == null)
            return false;
         
         var component:IEntityComponent = null;
         if (ComponentName != "")
         {
            component = componentObject.LookupComponentByName(ComponentName);
            if (component == null)
            {
               Logger.PrintError(Owner, "Deserialize", "Could not find component with name " + ComponentName + " on object " + ComponentReference + ".");
               return true;
            }
         }
         else
         {
            var componentType:String = TypeUtility.GetFieldType(Owner, FieldName);
            component = componentObject.LookupComponentByType(TypeUtility.GetClassFromName(componentType));
            if (component == null)
            {
               Logger.PrintError(Owner, "Deserialize", "Could not find component with type " + componentType + " on object " + ComponentReference + ".");
               return true;
            }
         }
         
         Owner[FieldName] = component;
         _ReportSuccess();
         return true;
      }
      
      // Component reference on the entity being deserialized when the reference was created.
      if (ComponentName != "")
      {
         var localComponent:IEntityComponent = CurrentEntity.LookupComponentByName(ComponentName);
         if (localComponent == null)
            return false;
         
         Owner[FieldName] = localComponent;
         _ReportSuccess();
         return true;
      }
      
      // Or instantiate a new entity.
      if (ObjectReference != "")
      {
         Owner[FieldName] = TemplateManager.Instance.InstantiateEntity(ObjectReference);
         _ReportSuccess();
         return true;
      }
      
      // Nope, none of the above!
      return false;
   }
   
   /**
    * Trigger a console report about any references that haven't been resolved.
    */
   public function ReportMissing():void
   {
      // Don't spam.
      if(ReportedMissing)
         return;
      ReportedMissing = true;
      
      var firstPart:String = Owner.toString() + "[" + FieldName + "] on entity '" + CurrentEntity.Name + "' - ";
      
      // Name reference.
      if(NameReference)
      {
         Logger.PrintWarning(this, "ReportMissing", firstPart + "Couldn't resolve reference to named entity '" + NameReference + "'");
         return; 
      }

      // Look up a component on a named object by name (first) or type (second).
      if (ComponentReference != "")
      {
         Logger.PrintWarning(this, "ReportMissing", firstPart + " Couldn't find named entity '" + ComponentReference + "'");
         return;
      }
      
      // Component reference on the entity being deserialized when the reference was created.
      if (ComponentName != "")
      {
         Logger.PrintWarning(this, "ReportMissing", firstPart + " Couldn't find component on same entity named '" + ComponentName + "'");
         return;
      }
   }
   
   private function _ReportSuccess():void
   {
      // If we succeeded with no spam then be quiet on success too.
      if(!ReportedMissing)
         return;

      var firstPart:String = Owner.toString() + "[" + FieldName + "] on entity '" + CurrentEntity.Name + "' - ";
      
      // Name reference.
      if(NameReference)
      {
         Logger.PrintWarning(this, "_ReportSuccess", firstPart + " After failure, was able to resolve reference to named entity '" + NameReference + "'");
         return; 
      }

      // Look up a component on a named object by name (first) or type (second).
      if (ComponentReference != "")
      {
         Logger.PrintWarning(this, "_ReportSuccess", firstPart + " After failure, was able to find named entity '" + ComponentReference + "'");
         return;
      }
      
      // Component reference on the entity being deserialized when the reference was created.
      if (ComponentName != "")
      {
         Logger.PrintWarning(this, "_ReportSuccess", firstPart + " After failure, was able to find component on same entity named '" + ComponentName + "'");
         return;
      }
   }
}

/**
 * Helper class to make sure metadata is being included.
 */
class TestForMetadata
{
   [TypeHint(type="Number")]
   public var SomeArray:Array;
}
