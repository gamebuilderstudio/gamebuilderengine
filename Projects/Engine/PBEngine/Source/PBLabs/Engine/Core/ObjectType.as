package PBLabs.Engine.Core
{
   import PBLabs.Engine.Serialization.ISerializable;
   
   /**
    * An ObjectType is an abstraction of a bitmask that can be used to associate
    * objects with type names.
    * 
    * @see ObjectTypeManager
    * @see ../../../../../Examples/ObjectTypes.html Using Object Types 
    */
   public class ObjectType implements ISerializable
   {
      /**
       * The bitmask that this type wraps. This should not be used directly. Instead,
       * use the various test methods on the ObjectTypeManager.
       * 
       * @see PBLabs.Engine.Core.ObjectTypeManager.DoesTypeMatch()
       * @see PBLabs.Engine.Core.ObjectTypeManager.DoesTypeOverlap()
       * @see PBLabs.Engine.Core.ObjectTypeManager.DoTypesMatch()
       * @see PBLabs.Engine.Core.ObjectTypeManager.DoTypesOverlap()
       */
      public function get Bits():int
      {
         return _bits;
      }
      
      /**
       * The name of the type associated with this object type. If multiple names have
       * been assigned, a random one is returned.
       */
      public function get TypeName():String
      {
         for (var i:int = 0; i < ObjectTypeManager.Instance.TypeCount; i++)
         {
            if (_bits & (1 << i))
               return ObjectTypeManager.Instance.GetTypeName(1 << i);
         }
         
         return "";
      }
      
      /**
       * @private
       */
      public function set TypeName(value:String):void
      {
         _bits = ObjectTypeManager.Instance.GetType(value);
      }
      
      /**
       * A list of all the type names associated with this object type.
       */
      public function get TypeNames():Array
      {
         var array:Array = new Array();
         for (var i:int = 0; i < ObjectTypeManager.Instance.TypeCount; i++)
         {
            if (_bits & (1 << i))
               array.push(ObjectTypeManager.Instance.GetTypeName(1 << i));
         }
         
         return array;
      }
      
      /**
       * @private
       */
      public function set TypeNames(value:Array):void
      {
         _bits = 0;
         for each (var typeName:String in value)
            _bits |= ObjectTypeManager.Instance.GetType(typeName);
      }
      
      /**
       * @inheritDoc
       */
      public function Serialize(xml:XML):void
      {
         var typeNames:Array = TypeNames;
         if (typeNames.length == 1)
         {
            xml.appendChild(typeNames[0]);
            return;
         }
         
         for each (var typeName:String in typeNames)
            xml.appendChild(<type>{typeName}</type>);
      }
      
      /**
       * The xml description for this class can be either a single string, which will
       * then be assigned to the TypeName property, or a list of strings, each in their
       * own child tag (the name of which doesn't matter).
       * 
       * @inheritDoc
       */
      public function Deserialize(xml:XML):void
      {
         if (xml.hasSimpleContent())
         {
            TypeName = xml.toString();
            return;
         }
         
         _bits = 0;
         for each (var childXML:XML in xml.*)
            _bits |= ObjectTypeManager.Instance.GetType(childXML.toString());
      }
      
      private var _bits:int = 0;
   }
}