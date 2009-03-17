package PBLabs.Engine.Serialization
{
   /**
    * Provides an interface for objects to override the default serialization
    * behavior.
    * 
    * <p>Any class implementing this interface will automatically have its
    * Serialize and Deserialize methods called in place of the default serialization
    * methods on the Serializer class.</p>
    * 
    * @see Serializer
    * @see ../../../../../Examples/CustomSerialization.html Custom Serialization
    */
   public interface ISerializable
   {
      /**
       * Serializes the object to XML. This should not include the main tag
       * defining the class itself.
       * 
       * @param xml The xml object to which the serialization of this class should
       * be added. This xml object is a single tag containing the main class definition,
       * so only children of this class should be added to it.
       * 
       * @see ../../../../../Examples/SerializingObjects.html Serializing Objects
       */
      function Serialize(xml:XML):void;
      
      /**
       * Deserializes the object from xml. The format of the xml passed is custom,
       * depending on the way the object was serialized with the Serialize method.
       * 
       * @param xml The xml containing the serialized definition of the class.
       * 
       * @see ../../../../../Examples/DeserializingObjects.html Deserializing Objects
       */
      function Deserialize(xml:XML):void;
   }
}