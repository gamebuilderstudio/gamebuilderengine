/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.serialization
{
   import com.pblabs.engine.debug.Logger;
   import com.pblabs.engine.entity.*;
   
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
       * Gets the singleton instance of the Serializer class.
       */
      public static function get instance():Serializer
      {
         if (!_instance)
            _instance = new Serializer();
         
         return _instance;
      }
      
      private static var _instance:Serializer = null;
      
      public function Serializer()
      {
         // initialize our default Serializers. Note "special" cases get a double
         // colon so there can be no overlap w/ any real type.
         _deSerializers["::DefaultSimple"] = _deserializeSimple;
         _deSerializers["::DefaultComplex"] = _deserializeComplex;
         _deSerializers["Boolean"] = _deserializeBoolean;
         _deSerializers["Array"] = _deserializeDictionary;
         _deSerializers["flash.utils::Dictionary"] = _deserializeDictionary;
         
         _Serializers["::DefaultSimple"] = _serializeSimple;
         _Serializers["::DefaultComplex"] = _serializeComplex;
         _Serializers["Boolean"] = _serializeBoolean;
         
         // Do a quick sanity check to make sure we are getting metadata.
         var tmd:TestForMetadata = new TestForMetadata();
         if(TypeUtility.getTypeHint(tmd, "SomeArray") != "Number")
            throw new Error("Metadata is not included in this build of the engine, so serialization will not work!\n" + 
            "Add --keep-as3-metadata+=TypeHint,EditorData,Embed to your compiler arguments to get around this.");
      }
      
      /**
       * serializes an object to XML. This is currently not implemented.
       * 
       * @param object The object to serialize. If this object implements ISerializable,
       * its serialize method will be called to do the serialization, otherwise the default
       * behavior will be used.
       * 
       * @return The xml describing the specified object.
       * 
       * @see ISerializable
       */
      public function serialize(object:*, xml:XML):void
      {
         if (object is ISerializable)
         {
            (object as ISerializable).serialize(xml);
         }
         else if (object is IEntity)
         {
            _currentEntity = object as IEntity;
            _currentEntity.serialize(xml);
         }
         else
         {
            // Normal case - determine type and call the right Serializer.
            var typeName:String = TypeUtility.getObjectClassName(object);
            if (!_Serializers[typeName])
               typeName = _IsSimpleType(object) ? "::DefaultSimple" : "::DefaultComplex";
            
            _Serializers[typeName](object, xml);
         }
      }
      
      /**
       * deserializes an object from an xml description.
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
      public function deserialize(object:*, xml:XML, typeHint:String=null):*
      {
         // Dispatch our special cases - entities and ISerializables.
         if (object is ISerializable)
         {
            return ISerializable(object).deserialize(xml);
         }
         else if (object is IEntity)
         {
            _currentEntity = object as IEntity;
            _currentEntity.deserialize(xml, true);
            resolveReferences();
            return object as IEntity;
         }
         
         // Normal case - determine type and call the right Serializer.
         var typeName:String = TypeUtility.getObjectClassName(object);
         if (!_deSerializers[typeName])
            typeName = xml.hasSimpleContent() ? "::DefaultSimple" : "::DefaultComplex";
         
         return _deSerializers[typeName](object, xml, typeHint);
      }
      
      /**
       * Set the entity relative to which current serialization work is happening. Mostly for internal use.
       */
      public function setCurrentEntity(e:IEntity):void
      {
         _currentEntity = e;
      }
      
      /**
       * Clear the entity relative to which current serialization work is happening. Mostly for internal use.
       */
      public function clearCurrentEntity():void
      {
         _currentEntity = null;
      }
      
      /**
       * Not all references are resolved immediately. In order to minimize spam,
       * we only report "dangling references" at certain times. This method 
       * triggers such a report.
       */
      public function reportMissingReferences():void
      {
         for (var i:int = 0; i < _deferredReferences.length; i++)
         {
            var reference:ReferenceNote = _deferredReferences[i];
            reference.reportMissing();
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
         var typeName:String = TypeUtility.getObjectClassName(object);
         if (typeName == "String" || typeName == "int" || typeName == "Number" || typeName == "uint" || typeName == "Boolean")
            return true;
         
         return false;
      }
      
      private function _deserializeSimple(object:*, xml:XML, typeHint:String):*
      {
         // If the tag is empty and we're not a string where """ is a valid value,
         // just return that value.
         if (xml.toString() == "" && !(object is String))
            return object;
         
         return xml.toString();
      }
      
      private function _serializeSimple(object:*, xml:XML):void
      {
         xml.appendChild(object.toString());
      }
      
      private function _deserializeComplex(object:*, xml:XML, typeHint:String):*
      {
         var isDynamic:Boolean = (object is Array) || (object is Dictionary) || (TypeUtility.isDynamic(object));
         
         for each (var fieldXML:XML in xml.*)
         {
            // Figure out the field we're setting, and make sure it is present.
            var fieldName:String = fieldXML.name().toString();
            if (!object.hasOwnProperty(fieldName) && !isDynamic)
            {
               Logger.printWarning(object, "deserialize", "The field '" + fieldName + "' does not exist on the class " + TypeUtility.getObjectClassName(object) + ".");
               continue;
            }
            
            // Determine the type.
            var typeName:String = fieldXML.attribute("type");
            if (typeName.length < 1)
               typeName = TypeUtility.getFieldType(object, fieldName);
            if (isDynamic && typeName == null)
               typeName = "String";
            
            // deserialize into the child.
            if (!_GetChildReference(object, fieldName, fieldXML) && !getResourceObject(object, fieldName, fieldXML))
            {
               var child:* = _GetChildObject(object, fieldName, typeName);
               if (child)
               {
                  // Deal with typehints.
                  var childTypeHint:String = TypeUtility.getTypeHint(object, fieldName);
                  child = deserialize(child, fieldXML, childTypeHint);
               }
               
               // Assign the new value.
               try
               {
                  object[fieldName] = child;
               }
               catch(e:Error)
               {
                  Logger.printError(object, "deserialize", "The field " + fieldName + " could not be set to '" + child + "' due to:" + e.toString());
               }
            }
         }
         
         return object;
      }
      
      private function _serializeComplex(object:*, xml:XML):void
      {
         var classDescription:XML = TypeUtility.getTypeDescription(object);
         for each (var property:XML in classDescription.child("accessor"))
         {
            if (property.@access == "readwrite")
            {
               var propertyName:String = property.@name;
               var propertyXML:XML = <{propertyName}/>
               serialize(object[propertyName], propertyXML);
               xml.appendChild(propertyXML);
            }
         }
         
         for each (var field:XML in classDescription.child("variable"))
         {
            var fieldName:String = field.@name;
            var fieldXML:XML = <{fieldName}/>
            serialize(object[fieldName], fieldXML);
            xml.appendChild(fieldXML);
         }
      }
      
      private function _deserializeBoolean(object:*, xml:XML, typeHint:String):*
      {
         return (xml.toString() == "true")
      }
      
      private function _serializeBoolean(object:*, xml:XML):void
      {
         if (object)
            xml.appendChild("true");
         else
            xml.appendChild("false");
      }
      
      private function _deserializeDictionary(object:*, xml:XML, typeHint:String):*
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
               Logger.printError(object, "deserialize", "Cannot add a value to a dictionary without a key.");
               continue;
            }
            
            // Infer the type.
            var typeName:String = childXML.attribute("type");
            if (typeName.length < 1)
               typeName = xml.attribute("childType");
            
            if (typeName == null || typeName == "")
               typeName = typeHint ? typeHint : "String";
            
            // deserialize the value.
            if (!_GetChildReference(object, key, childXML) && !getResourceObject(object, key, childXML, typeHint))
            {
               var value:* = _GetChildObject(object, key, typeName);
               if (value != null)
                  value = deserialize(value, childXML);
               
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
         
         if (nameReference != "" || componentReference != "" || componentName != "" || objectReference != "")
         {
            var reference:ReferenceNote = new ReferenceNote();
            reference.owner = object;
            reference.FieldName = fieldName;
            reference.NameReference = nameReference;
            reference.ComponentReference = componentReference;
            reference.ComponentName = componentName
            reference.ObjectReference = objectReference;
            reference.CurrentEntity = _currentEntity;
            
            if (!reference.resolve())
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
         
         if (!childObject)
            childObject = TypeUtility.instantiate(typeName);
         
         if (!childObject)
         {
            Logger.printError(object, "deserialize", "Unable to create type " + typeName + " for the field " + fieldName + ".");
            return null;
         }
         
         return childObject;
      }
      
      private function getResourceObject(object:*, fieldName:String, xml:XML, typeHint:String = null):Boolean
      {
         var filename:String = xml.attribute("filename");
         if (filename == "")
            return false;
            
         var type:Class = null;
         if(typeHint)
            type = TypeUtility.getClassFromName(typeHint);
         else
            type = TypeUtility.getClassFromName(TypeUtility.getFieldType(object, fieldName));
         
         var resource:ResourceNote = new ResourceNote();
         resource.owner = object;
         resource.fieldName = fieldName;
         resource.load(filename, type);
         
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
      
      public function resolveReferences():void
      {
         for (var i:int = 0; i < _deferredReferences.length; i++)
         {
            var reference:ReferenceNote = _deferredReferences[i];
            if (reference.resolve())
            {
               _deferredReferences.splice(i, 1);
               i--;
            }
         }
      }
      
      private var _currentEntity:IEntity = null;
      private var _Serializers:Dictionary = new Dictionary();
      private var _deSerializers:Dictionary = new Dictionary();
      private var _deferredReferences:Array = new Array();
      private var _resources:Dictionary = new Dictionary();
   }
}

import com.pblabs.engine.entity.IEntity;
import com.pblabs.engine.entity.IEntityComponent;
import com.pblabs.engine.debug.Logger;
import com.pblabs.engine.core.NameManager;
import com.pblabs.engine.core.TemplateManager;
import com.pblabs.engine.serialization.TypeUtility;
import com.pblabs.engine.resource.Resource;
import com.pblabs.engine.resource.ResourceManager;
import com.pblabs.engine.serialization.Serializer;

internal class ResourceNote
{
   public var owner:* = null;
   public var fieldName:String = null;
   
   public function load(filename:String, type:Class):void
   {
      ResourceManager.instance.load(filename, type, onLoaded, onFailed);
   }
   
   public function onLoaded(resource:Resource):void
   {
      owner[fieldName] = resource;
      Serializer.instance._RemoveResource(resource.filename);
   }
   
   public function onFailed(resource:Resource):void
   {
      Logger.printError(owner, "set " + fieldName, "No resource was found with filename " + resource.filename + ".");
      Serializer.instance._RemoveResource(resource.filename);
   }
}

internal class ReferenceNote
{
   public var owner:* = null;
   public var FieldName:String = null;
   public var NameReference:String = null;
   public var ComponentReference:String = null;
   public var ComponentName:String = null;
   public var ObjectReference:String = null;
   public var CurrentEntity:IEntity = null;
   public var ReportedMissing:Boolean = false;
   
   public function resolve():Boolean
   {
      // Look up by name.
      if (NameReference != "")
      {
         var namedObject:IEntity = NameManager.instance.lookup(NameReference);
         if (!namedObject)
            return false;
         
         owner[FieldName] = namedObject;
         _ReportSuccess();
         return true;
      }
      
      // Look up a component on a named object by name (first) or type (second).
      if (ComponentReference != "")
      {
         var componentObject:IEntity = NameManager.instance.lookup(ComponentReference);
         if (!componentObject)
            return false;
         
         var component:IEntityComponent = null;
         if (ComponentName != "")
         {
            component = componentObject.lookupComponentByName(ComponentName);
            if (!component)
               return false;
         }
         else
         {
            var componentType:String = TypeUtility.getFieldType(owner, FieldName);
            component = componentObject.lookupComponentByType(TypeUtility.getClassFromName(componentType));
            if (!component)
               return false;
         }
         
         owner[FieldName] = component;
         _ReportSuccess();
         return true;
      }
      
      // Component reference on the entity being deserialized when the reference was created.
      if (ComponentName != "")
      {
         var localComponent:IEntityComponent = CurrentEntity.lookupComponentByName(ComponentName);
         if (!localComponent)
            return false;
         
         owner[FieldName] = localComponent;
         _ReportSuccess();
         return true;
      }
      
      // Or instantiate a new entity.
      if (ObjectReference != "")
      {
         owner[FieldName] = TemplateManager.instance.instantiateEntity(ObjectReference);
         _ReportSuccess();
         return true;
      }
      
      // Nope, none of the above!
      return false;
   }
   
   /**
    * Trigger a console report about any references that haven't been resolved.
    */
   public function reportMissing():void
   {
      // Don't spam.
      if(ReportedMissing)
         return;
      ReportedMissing = true;
      
      var firstPart:String = owner.toString() + "[" + FieldName + "] on entity '" + CurrentEntity.name + "' - ";
      
      // Name reference.
      if(NameReference)
      {
         Logger.printWarning(this, "reportMissing", firstPart + "Couldn't resolve reference to named entity '" + NameReference + "'");
         return; 
      }

      // Look up a component on a named object by name (first) or type (second).
      if (ComponentReference != "")
      {
         Logger.printWarning(this, "reportMissing", firstPart + " Couldn't find named entity '" + ComponentReference + "'");
         return;
      }
      
      // Component reference on the entity being deserialized when the reference was created.
      if (ComponentName != "")
      {
         Logger.printWarning(this, "reportMissing", firstPart + " Couldn't find component on same entity named '" + ComponentName + "'");
         return;
      }
   }
   
   private function _ReportSuccess():void
   {
      // If we succeeded with no spam then be quiet on success too.
      if(!ReportedMissing)
         return;

      var firstPart:String = owner.toString() + "[" + FieldName + "] on entity '" + CurrentEntity.name + "' - ";
      
      // Name reference.
      if(NameReference)
      {
         Logger.printWarning(this, "_ReportSuccess", firstPart + " After failure, was able to resolve reference to named entity '" + NameReference + "'");
         return; 
      }

      // Look up a component on a named object by name (first) or type (second).
      if (ComponentReference != "")
      {
         Logger.printWarning(this, "_ReportSuccess", firstPart + " After failure, was able to find named entity '" + ComponentReference + "'");
         return;
      }
      
      // Component reference on the entity being deserialized when the reference was created.
      if (ComponentName != "")
      {
         Logger.printWarning(this, "_ReportSuccess", firstPart + " After failure, was able to find component on same entity named '" + ComponentName + "'");
         return;
      }
   }
}
