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
      public function get TypeMap():Dictionary
      {
         throw new Error("Derived classes must implement this!");
      }
      
      /**
       * This must be implemented by subclasses. It is the type to use when a string
       * isn't found in the TypeMap.
       */
      public function get DefaultType():Enumerable
      {
         throw new Error("Derived classes must implement this!");
      }
      
      /**
       * @inheritDoc
       */
      public function Serialize(xml:XML):void
      {
         for (var typeName:String in TypeMap)
         {
            if (TypeMap[typeName] == this)
            {
               xml.appendChild(typeName);
               break;
            }
         }
      }
      
      /**
       * @inheritDoc
       */
      public function Deserialize(xml:XML):*
      {
         var stringValue:String = xml.toString();
         if (TypeMap[stringValue] == null)
         {
            Logger.PrintError(this, "Deserialize", stringValue + " is not a valid value for this enumeration.");
            return DefaultType;
         }
         
         return TypeMap[stringValue];
      }
   }
}