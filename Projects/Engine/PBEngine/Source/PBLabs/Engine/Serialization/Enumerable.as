package PBLabs.Engine.Serialization
{
   import PBLabs.Engine.Debug.Logger;
   
   import flash.utils.Dictionary;
   
   public class Enumerable implements ISerializable
   {
      public function get TypeMap():Dictionary
      {
         throw new Error("Derived classes must implement this!");
      }
      
      public function get DefaultType():Enumerable
      {
         throw new Error("Derived classes must implement this!");
      }
      
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