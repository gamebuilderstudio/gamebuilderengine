/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.rendering2D
{
   import com.pblabs.engine.resource.Resource;
   
   import flash.display.Bitmap;
   
   [EditorData(extensions="jpg,png,gif")]
   
   /**
    * This is a Resource subclass for image data.
    */
   public class ImageResource extends Resource
   {
      /**
       * Once the resource has succesfully loaded, this contains a bitmap representing
       * the loaded image.
       */
      public function get image():Bitmap
      {
         return _image;
      }
      
      override public function initialize(data:*):void
      {
          // Directly load embedded resources if they gave us a Bitmap.
          if(data is Bitmap)
          {
              onContentReady(data);
              onLoadComplete();
              return;
          }
          
          // Otherwise it must be a ByteArray, pass it over to the normal path.
          super.initialize(data);
      }

      /**
       * @inheritDoc
       */
      override protected function onContentReady(content:*):Boolean 
      {
         if(content)
            _image = content as Bitmap;
         return _image != null;
      }
      
      private var _image:Bitmap = null;
   }
}