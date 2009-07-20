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
   import PBLabs.Engine.Debug.Logger;
   
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
      public function get IsLoaded():Boolean
      {
         return ImageData != null;
      }

      /**
      * Specifies an offset so the sprite is centered correctly. If it is not
      * set, the sprite is centered.
      */
      public function get Center():Point
      {
         return _Center;
      }
      
      public function set Center(v:Point):void
      {
         _Center = v;
         _defaultCenter = false;
      }
      
      /**
       * The filename of the image to use for this sprite sheet.
       */
      [EditorData(ignore="true")]
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
         
         ResourceManager.Instance.Load(value, ImageResource, _OnImageLoaded, _OnImageFailed);
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
       * The number of directions per frame.
       */
      [EditorData(defaultValue="1")]
      public var DirectionsPerFrame:Number = 1;
      
      /**
       * The number of degrees separating each direction.
       */
      public function get DegreesPerDirection():Number
      {
         return 360 / DirectionsPerFrame;
      }
      
      /**
       * The total number of frames the sprite sheet has. This counts each
       * direction separately.
       */
      public function get RawFrameCount():int
      {
         if (ImageData == null)
            return 0;
         
         if (_divider == null)
            return 1;
         
         return _divider.FrameCount;
      }
      
      /**
       * The number of frames the sprite sheet has. This counts each set of
       * directions as one frame.
       */
      public function get FrameCount():int
      {
         return RawFrameCount / DirectionsPerFrame;
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
      public function GetFrame(index:int, direction:Number=0.0):BitmapData
      {
         if(!ImageData)
            return null;
         
         // Make sure direction is in 0..360.
         while (direction < 0)
            direction += 360;
         
         while (direction > 360)
            direction -= 360;
         
         // Easy case if we only have one direction per frame.
         if (DirectionsPerFrame == 1)
            return _GetRawFrame(index);
         
         // Otherwise we have to do a search.
         
         // Make sure we have data to fulfill our requests from.
         if (_frameNotes == null)
            _GenerateFrameNotes();
         
         // Look for best match.
         var bestMatchIndex:int = -1;
         var bestMatchDirectionDistance:Number = Number.POSITIVE_INFINITY;
         
         for (var i:int = 0; i < _frameNotes.length; i++)
         {
            var note:FrameNote = _frameNotes[i];
            if (note.Frame != index)
               continue;
            
            if (Math.abs(note.Direction - direction) < bestMatchDirectionDistance)
            {
               // This one is better on both frame and heading.
               bestMatchDirectionDistance = Math.abs(note.Direction - direction);
               bestMatchIndex = note.RawFrame;
            }
         }
         
         // Return the bitmap.
         if (bestMatchIndex >= 0)
            return _GetRawFrame(bestMatchIndex);
         
         return null;
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
         }
         else
         {
            _frames = new Array(_divider.FrameCount);
            for (var i:int = 0; i < _divider.FrameCount; i++)
            {
               var area:Rectangle = _divider.GetFrameArea(i);
               _frames[i] = new BitmapData(area.width, area.height, true);
               _frames[i].copyPixels(ImageData, area, new Point(0, 0));
            }
         }
         
         if (_defaultCenter)
            _Center = new Point(_frames[0].width * 0.5, _frames[0].height * 0.5);
      }
      
      protected function _OnImageLoaded(resource:ImageResource):void
      {
         Image = resource;
      }
      
      protected function _OnImageFailed(resource:ImageResource):void
      {
         Logger.PrintError(this, "_OnImageFailed", "Failed to load '" + resource.Filename + "'");
      }
      
      /**
       * Gets the frame at the specified index. This does not take direction into
       * account.
       */
      protected function _GetRawFrame(index:int):BitmapData
      {
         if (_frames == null)
            _BuildFrames();
         
         if (_frames == null)
            return null;
         
         if ((index < 0) || (index >= RawFrameCount))
            return null;
       
         return _frames[index];  
      }
      
      private function _GenerateFrameNotes():void
      {
         _frameNotes = new Array();
         
         var totalStates:int = FrameCount / DegreesPerDirection;
         
         for (var direction:int = 0; direction < DirectionsPerFrame; direction++)
         {
            for (var frame:int = 0; frame < FrameCount; frame++)
            {
               var note:FrameNote = new FrameNote();
               note.Frame = frame;
               note.Direction = direction * DegreesPerDirection;
               note.RawFrame = (direction * FrameCount) + frame;
               
               _frameNotes.push(note);
            }
         }
      }
      
      private var _frameNotes:Array;
         
      private var _image:ImageResource = null;
      private var _divider:ISpriteSheetDivider = null;
      private var _frames:Array = null;
      private var _Center:Point = new Point(0, 0);
      private var _defaultCenter:Boolean = true;
   }
}

final class FrameNote
{
   public var Frame:int;
   public var Direction:Number;
   public var RawFrame:int;
}
