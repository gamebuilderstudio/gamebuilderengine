package PBLabs.Engine.Resource
{
   import flash.utils.ByteArray;
   import PBLabs.Engine.Debug.*;
   
   /**
    * This is a Resource subclass for XML data.
    */
   public class XMLResource extends Resource
   {
      /**
       * The loaded XML. This will be null until loading of the resource has completed.
       */
      public function get XMLData():XML
      {
         return _xml;
      }
      
      /**
       * The data loaded from an XML file is just a string containing the xml itself,
       * so we don't need any special loading. This just converts the byte array to
       * a string and marks the resource as loaded.
       */
      public override function Initialize(data:ByteArray):void
      {
         try
         {
            _xml = new XML(data.toString());
         }
         catch (e:TypeError)
         {
            Logger.Print(this, "Got type error parsing XML: " + e.toString());
            _valid = false;
         }
         
         _OnLoadComplete();
      }
      
      /**
       * @inheritDoc
       */
      protected override function _OnContentReady(content:*):Boolean 
      {
         return _valid;
      }
      
      private var _valid:Boolean = true;
      private var _xml:XML = null;
   }
}