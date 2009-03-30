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
   import PBLabs.Engine.Entity.EntityComponent;
   import PBLabs.Engine.Resource.ResourceManager;
   
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   /**
    * Handles loading and retrieving data about a sprite sheet to use for rendering.
    * 
    * <p>Be aware that Flash implements an upper limit on image size - going over
    * 2048 pixels in any dimension will lead to problems.</p>
    */ 
   public class SpriteSheetComponent extends EntityComponent
   {
      /**
       * True if the image data associated with this sprite sheet has been loaded.
       */
      public function get IsLoaded():Boolean
      {
         return ImageData != null;
      }
      
      /**
       * The filename of the image to use for this sprite sheet.
       */
      public function get ImageFilename():String
      {
         return _image == null ? null : _image.Filename;
      }
      
      /**
       * @private
       */
      public function set ImageFilename(value:String):void
      {
         if (_image != null)
         {
            ResourceManager.Instance.Unload(_image.Filename, ImageResource);
            Image = null;
         }
         
         ResourceManager.Instance.Load(value, ImageResource, _OnImageLoaded);
      }
      
      /**
       * The image resource to use for this sprite sheet.
       */
      public function get Image():ImageResource
      {
         return _image;
      }
      
      /**
       * @private
       */
      public function set Image(value:ImageResource):void
      {
         _frames = null;
         _image = value;
      }
      
      /**
       * The bitmap data of the loaded image.
       */
      public function get ImageData():BitmapData
      {
         if (_image == null)
            return null;
         
         return _image.Image.bitmapData;
      }
      
      /**
       * The divider to use to chop up the sprite sheet into frames. If the divider
       * isn't set, the image will be treated as one whole frame.
       */
      public function get Divider():ISpriteSheetDivider
      {
         return _divider;
      }
      
      /**
       * @private
       */
      public function set Divider(value:ISpriteSheetDivider):void
      {
         _divider = value;
         _divider.OwningSheet = this;
         _frames = null;
      }
      
      /**
       * The number of frames the sprite sheet has.
       */
      public function get FrameCount():int
      {
         if (ImageData == null)
            return 0;
         
         if (_divider == null)
            return 1;
         
         return _divider.FrameCount;
      }
      
      /**
       * Gets the bitmap data for a frame at the specified index.
       * 
       * @param index The index of the frame to retrieve.
       * 
       * @return The bitmap data for the specified frame, or null if it doesn't exist.
       */
      public function GetFrame(index:int):BitmapData
      {
         if (_frames == null)
            _BuildFrames();
         
         if (_frames == null)
            return null;
         
         if ((index < 0) || (index >= FrameCount))
            return null;
       
         return _frames[index];  
      }
      
      protected function _BuildFrames():void
      {
         // image isn't loaded, can't do anything yet
         if (ImageData == null)
            return;
         
         // no divider means treat the image as a single frame
         if (_divider == null)
         {
            _frames = new Array(1);
            _frames[0] = ImageData;
            return;
         }
         
         _frames = new Array(_divider.FrameCount);
         for (var i:int = 0; i < _divider.FrameCount; i++)
         {
            var area:Rectangle = _divider.GetFrameArea(i);
            _frames[i] = new BitmapData(area.width, area.height);
            _frames[i].copyPixels(ImageData, area, new Point(0, 0));
         }
      }
      
      protected function _OnImageLoaded(resource:ImageResource):void
      {
         Image = resource;
      }
         
      private var _image:ImageResource = null;
      private var _divider:ISpriteSheetDivider = null;
      private var _frames:Array = null;
   }
}