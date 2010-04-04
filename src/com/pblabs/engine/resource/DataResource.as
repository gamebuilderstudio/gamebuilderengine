/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
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
      public function get data():ByteArray
      {
         return _data;
      }
      
      /**
       * @inheritDoc
       */
      override public function initialize(data:*):void
      {
         if(!(data is ByteArray))
            throw new Error("DataResource can only handle ByteArrays.");
            
         _data = data;
         onLoadComplete();
      }
      
      /**
       * @inheritDoc
       */
      override protected function onContentReady(content:*):Boolean 
      {
         return _data != null;
      }
      
      private var _data:ByteArray = null;
   }
}