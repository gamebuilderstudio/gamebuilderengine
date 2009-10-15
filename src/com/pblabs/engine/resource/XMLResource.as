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
   import com.pblabs.engine.debug.Logger;
   
   import flash.utils.ByteArray;
   
   [EditorData(extensions="xml")]
   
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
      override public function initialize(data:*):void
      {
         if (data is ByteArray)
         {
         	// convert ByteArray data to a string
         	data = (data as ByteArray).readUTFBytes((data as ByteArray).length);
         }
            
         try
         {
            _xml = new XML(data);
         }
         catch (e:TypeError)
         {
            Logger.print(this, "Got type error parsing XML: " + e.toString());
            _valid = false;
         }
         
         onLoadComplete();
      }
      
      /**
       * @inheritDoc
       */
      override protected function onContentReady(content:*):Boolean 
      {
         return _valid;
      }
      
      private var _valid:Boolean = true;
      private var _xml:XML = null;
   }
}