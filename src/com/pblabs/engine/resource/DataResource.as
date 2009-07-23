package com.pblabs.engine.resource
{
   import flash.utils.ByteArray;
   
   /**
    * This is a Resource subclass for arbitrary data.
    */
   public class DataResource extends Resource
   {
      /**
       * The loaded data. This will be null until loading of the resource has completed.
       */
      public function get Data():ByteArray
      {
         return _data;
      }
      
      /**
       * @inheritDoc
       */
      public override function Initialize(data:*):void
      {
         if(!(data is ByteArray))
            throw new Error("DataResource can only handle ByteArrays.");
            
         _data = data;
         _OnLoadComplete();
      }
      
      /**
       * @inheritDoc
       */
      protected override function _OnContentReady(content:*):Boolean 
      {
         return _data != null;
      }
      
      private var _data:ByteArray = null;
   }
}