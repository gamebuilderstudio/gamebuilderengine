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
   
   import flash.utils.Dictionary;
   import flash.utils.describeType;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   /**
    * TypeUtility is a static class containing methods that aid in type
    * introspection and reflection.
    */
   public class TypeUtility
   {
      /**
       * Registers a function that will be called when the specified type needs to be
       * instantiated. The function should return an instance of the specified type.
       * 
       * @param typeName The name of the type the specified function should handle.
       * @param instantiator The function that instantiates the specified type.
       */
      public static function RegisterInstantiator(typeName:String, instantiator:Function):void
      {
         if (_instantiators[typeName] != null)
            Logger.PrintWarning("TypeUtility", "RegisterInstantiator", "An instantiator for " + typeName + " has already been registered. It will be replaced.");
         
         _instantiators[typeName] = instantiator;
      }
      
      /**
       * Returns the fully qualified name of the type
       * of the passed in object.
       * 
       * @param object The object whose type is being retrieved.
       * 
       * @return The name of the specified object's type.
       */
      public static function GetObjectClassName(object:*):String
      {
         return flash.utils.getQualifiedClassName(object);
      }
      
      /**
       * Returns the Class object for the given class.
       * 
       * @param className The fully qualified name of the class being looked up.
       * 
       * @return The Class object of the specified class, or null if wasn't found.
       */
      public static function GetClassFromName(className:String):Class
      {
         return getDefinitionByName(className) as Class;
      }
      
      /**
       * Creates an instance of a type based on its name.
       * 
       * @param className The name of the class to instantiate.
       * 
       * @return An instance of the class, or null if instantiation failed.
       */
      public static function Instantiate(className:String):*
      {
         // Deal with strings explicitly as they are a primitive.
         if (className == "String")
            return "";
         
         // Check for overrides.
         if (_instantiators[className] != null)
            return _instantiators[className]();
         
         // Give it a shot!
         try
         {
            return new (getDefinitionByName(className));
         }
         catch (e:Error)
         {
            Logger.PrintWarning(null, "Instantiate", "Failed to instantiate " + className + " due to " + e.toString());
         }
         
         // If we get here, couldn't new it.
         return null;
      }
      
      /**
       * Gets the type of a field as a string for a specific field on an object.
       * 
       * @param object The object on which the field exists.
       * @param field The name of the field whose type is being looked up.
       * 
       * @return The fully qualified name of the type of the specified field, or
       * null if the field wasn't found.
       */
      public static function GetFieldType(object:*, field:String):String
      {
         var typeXML:XML = GetTypeDescription(object);
         
         // Look for a matching accessor.
         for each(var property:XML in typeXML.child("accessor"))
         {
            if (property.attribute("name") == field)
               return property.attribute("type");
         }
         
         // Look for a matching variable.
         for each(var variable:XML in typeXML.child("variable"))
         {
            if (variable.attribute("name") == field)
               return variable.attribute("type");
         }
                  
         return null;
      }
      
      /**
       * Determines if an object is an instance of a dynamic class.
       * 
       * @param object The object to check.
       * 
       * @return True if the object is dynamic, false otherwise.
       */
      public static function IsDynamic(object:*):Boolean
      {
           if (object is Class)
           {
              Logger.PrintError(object, "IsDynamic", "The object is a Class type, which is always dynamic");
              return true;
           }
   
           var typeXml:XML = GetTypeDescription(object);
           return typeXml.@isDynamic == "true";
      }
      
      public static function GetTypeHint(object:*, field:String):String
      {
         var description:XML = GetTypeDescription(object);
         if (description == null)
            return null;
         
         for each (var variable:XML in description.*)
         {
            if ((variable.name() != "variable") && (variable.name() != "accessor"))
               continue;
            
            if (variable.@name == field)
            {
               for each (var metadataXML:XML in variable.*)
               {
                  if (metadataXML.@name == "TypeHint")
                     return metadataXML.arg.@value.toString();
               }
            }
         }
         
         return null;
      }
      
      /**
       * Gets the xml description of an object's type through a call to the
       * flash.utils.describeType method. Results are cached, so only the first
       * call will impact performance.
       * 
       * @param object The object to describe.
       * 
       * @return The xml description of the object.
       */
      public static function GetTypeDescription(object:*):XML
      {
         var className:String = GetObjectClassName(object);
         if (_typeDescriptions[className] == null)
            _typeDescriptions[className] = describeType(object);
            
         return _typeDescriptions[className];
      }
      
      private static var _typeDescriptions:Dictionary = new Dictionary();
      private static var _instantiators:Dictionary = new Dictionary();
   }
}