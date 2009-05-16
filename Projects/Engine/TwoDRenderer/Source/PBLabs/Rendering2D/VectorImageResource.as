/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Rendering2D
{
   import PBLabs.Engine.Resource.Resource;
   
   import flash.display.DisplayObject;
   
   /**
    * This is a Resource subclass for image data.
    */
   public class VectorImageResource extends Resource
   {
      /**
       * Once the resource has succesfully loaded, this contains a bitmap representing
       * the loaded image.
       */
      public function get Image():DisplayObject
      {
         return _image;
      }
      
      /**
       * @inheritDoc
       */
      override protected function _OnContentReady(content:*):Boolean 
      {
         _image = content as DisplayObject;
         return _image != null;
      }
      
      private var _image:DisplayObject = null;
   }
}