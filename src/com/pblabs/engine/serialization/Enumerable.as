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
   
   import flash.utils.Dictionary;
   
   [EditorData(ignore="true")]
   
   /**
    * Base class that implements common functionality for enumeration classes. An
    * enumeration class is essentially a class that is just a list of constant
    * values. They can be used to add type safety to properties that need to be
    * limited to a specific subset of values.
    * 
    * <p>Serialization is also provided by this class so the names of the constants
    * can be used in XML rather than their values.</p>
    */
   public class Enumerable implements ISerializable
   {
      /**
       * This must be implemented by subclasses. It is a dictionary that maps the names
       * of enumerable values to the instance of the enumerable they represent.
       */
      public function get typeMap():Dictionary
      {
         throw new Error("Derived classes must implement this!");
      }
      
      /**
       * This must be implemented by subclasses. It is the type to use when a string
       * isn't found in the TypeMap.
       */
      public function get defaultType():Enumerable
      {
         throw new Error("Derived classes must implement this!");
      }
      
      /**
       * @inheritDoc
       */
      public function serialize(xml:XML):void
      {
         for (var typeName:String in typeMap)
         {
            if (typeMap[typeName] == this)
            {
               xml.appendChild(typeName);
               break;
            }
         }
      }
      
      /**
       * @inheritDoc
       */
      public function deserialize(xml:XML):*
      {
         var stringValue:String = xml.toString();
         if (!typeMap[stringValue])
         {
            Logger.error(this, "deserialize", stringValue + " is not a valid value for this enumeration.");
            return defaultType;
         }
         
         return typeMap[stringValue];
      }
   }
}