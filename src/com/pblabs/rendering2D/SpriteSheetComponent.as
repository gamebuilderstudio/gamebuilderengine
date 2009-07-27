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
   import com.pblabs.engine.entity.EntityComponent;
   import com.pblabs.engine.resource.ResourceManager;
   import com.pblabs.engine.debug.Logger;
   
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   /**
    * Handles loading and retrieving data about a sprite sheet to use for rendering.
    * 
    * <p>Functionality exists to allow several directions to be specified per frame.
    * This enables you to, for instance, visually rotate a sprite without rotating
    * the actual object it belongs to.</p>
    * 
    * <p>Because we may group them in different ways, we distinguish between
    * "raw frames" and a "frame" which might be made up of multiple directions.</p>
    * 
    * <p>On the subject of sprite sheet order: the divider may alter this, but in
    * general, frames are numbered left to right, top to bottom. If you have a 4
    * direction sprite sheet, then 0,1,2,3 will be frame 1, 4,5,6,7 will be 2,
    * and so on.</p>
    * 
    * <p>Be aware that Flash implements an upper limit on image size - going over
    * 2048 pixels in any dimension will lead to problems.</p>
    */ 
   public class SpriteSheetComponent extends EntityComponent
   {
      /**
       * True if the image data associated with this sprite sheet has been loaded.
       */
      public function get isLoaded():Boolean
      {
         return imageData != null;
      }

      /**
      * Specifies an offset so the sprite is centered correctly. If it is not
      * set, the sprite is centered.
      */
      public function get center():Point
      {
         return _center;
      }
      
      public function set center(value:Point):void
      {
         _center = value;
         _defaultCenter = false;
      }
      
      /**
       * The filename of the image to use for this sprite sheet.
       */
      [EditorData(ignore="true")]
      public function get imageFilename():String
      {
         return _image == null ? null : _image.filename;
      }
      
      /**
       * @private
       */
      public function set imageFilename(value:String):void
      {
         if (_image)
         {
            ResourceManager.instance.unload(_image.filename, ImageResource);
            image = null;
         }
         
         ResourceManager.instance.load(value, ImageResource, onImageLoaded, onImageFailed);
      }
      
      /**
       * The image resource to use for this sprite sheet.
       */
      public function get image():ImageResource
      {
         return _image;
      }
      
      /**
       * @private
       */
      public function set image(value:ImageResource):void
      {
         _frames = null;
         _image = value;
      }
      
      /**
       * The bitmap data of the loaded image.
       */
      public function get imageData():BitmapData
      {
         if (!_image)
            return null;
         
         return _image.image.bitmapData;
      }
      
      /**
       * The divider to use to chop up the sprite sheet into frames. If the divider
       * isn't set, the image will be treated as one whole frame.
       */
      public function get divider():ISpriteSheetDivider
      {
         return _divider;
      }
      
      /**
       * @private
       */
      public function set divider(value:ISpriteSheetDivider):void
      {
         _divider = value;
         _divider.owningSheet = this;
         _frames = null;
      }
      
      /**
       * The number of directions per frame.
       */
      [EditorData(defaultValue="1")]
      public var directionsPerFrame:Number = 1;
      
      /**
       * The number of degrees separating each direction.
       */
      public function get degreesPerDirection():Number
      {
         return 360 / directionsPerFrame;
      }
      
      /**
       * The total number of frames the sprite sheet has. This counts each
       * direction separately.
       */
      public function get rawFrameCount():int
      {
         if (!imageData)
            return 0;
         
         if (!_divider)
            return 1;
         
         return _divider.frameCount;
      }
      
      /**
       * The number of frames the sprite sheet has. This counts each set of
       * directions as one frame.
       */
      public function get frameCount():int
      {
         return rawFrameCount / directionsPerFrame;
      }
      
      /**
       * Gets the bitmap data for a frame at the specified index.
       * 
       * @param index The index of the frame to retrieve.
       * @param direction The direction of the frame to retrieve in degrees. This
       *                  can be ignored if there is only 1 direction per frame.
       * 
       * @return The bitmap data for the specified frame, or null if it doesn't exist.
       */
      public function getFrame(index:int, direction:Number=0.0):BitmapData
      {
         if(!imageData)
            return null;
         
         // Make sure direction is in 0..360.
         while (direction < 0)
            direction += 360;
         
         while (direction > 360)
            direction -= 360;
         
         // Easy case if we only have one direction per frame.
         if (directionsPerFrame == 1)
            return getRawFrame(index);
         
         // Otherwise we have to do a search.
         
         // Make sure we have data to fulfill our requests from.
         if (!_frameNotes)
            generateFrameNotes();
         
         // Look for best match.
         var bestMatchIndex:int = -1;
         var bestMatchDirectionDistance:Number = Number.POSITIVE_INFINITY;
         
         for (var i:int = 0; i < _frameNotes.length; i++)
         {
            var note:FrameNote = _frameNotes[i];
            if (note.frame != index)
               continue;
            
            if (Math.abs(note.direction - direction) < bestMatchDirectionDistance)
            {
               // This one is better on both frame and heading.
               bestMatchDirectionDistance = Math.abs(note.direction - direction);
               bestMatchIndex = note.rawFrame;
            }
         }
         
         // Return the bitmap.
         if (bestMatchIndex >= 0)
            return getRawFrame(bestMatchIndex);
         
         return null;
      }
      
      protected function buildFrames():void
      {
         // image isn't loaded, can't do anything yet
         if (!imageData)
            return;
         
         // no divider means treat the image as a single frame
         if (!_divider)
         {
            _frames = new Array(1);
            _frames[0] = imageData;
         }
         else
         {
            _frames = new Array(_divider.frameCount);
            for (var i:int = 0; i < _divider.frameCount; i++)
            {
               var area:Rectangle = _divider.getFrameArea(i);
               _frames[i] = new BitmapData(area.width, area.height, true);
               _frames[i].copyPixels(imageData, area, new Point(0, 0));
            }
         }
         
         if (_defaultCenter)
            _center = new Point(_frames[0].width * 0.5, _frames[0].height * 0.5);
      }
      
      protected function onImageLoaded(resource:ImageResource):void
      {
         image = resource;
      }
      
      protected function onImageFailed(resource:ImageResource):void
      {
         Logger.printError(this, "onImageFailed", "Failed to load '" + resource.filename + "'");
      }
      
      /**
       * Gets the frame at the specified index. This does not take direction into
       * account.
       */
      protected function getRawFrame(index:int):BitmapData
      {
         if (!_frames)
		 {
            buildFrames();
			return null;
		 }
         
         if (index < 0 || index >= rawFrameCount)
            return null;
       
         return _frames[index];  
      }
      
      private function generateFrameNotes():void
      {
         _frameNotes = new Array();
         
         var totalStates:int = frameCount / degreesPerDirection;
         
         for (var direction:int = 0; direction < directionsPerFrame; direction++)
         {
            for (var frame:int = 0; frame < frameCount; frame++)
            {
               var note:FrameNote = new FrameNote();
               note.frame = frame;
               note.direction = direction * degreesPerDirection;
               note.rawFrame = (direction * frameCount) + frame;
               
               _frameNotes.push(note);
            }
         }
      }
      
      private var _frameNotes:Array;
         
      private var _image:ImageResource = null;
      private var _divider:ISpriteSheetDivider = null;
      private var _frames:Array = null;
      private var _center:Point = new Point(0, 0);
      private var _defaultCenter:Boolean = true;
   }
}

final class FrameNote
{
   public var frame:int;
   public var direction:Number;
   public var rawFrame:int;
}
