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
    * Manages information relating to a spritesheet. Referenced by components
    * that draw sprites. Can support sheets with multiple directions per frame.
   *
   * Be aware that Flash implements an upper limit on image size - going over
   * 2048 pixels in any dimension will lead to problems.
   *
   * Because we may group them in different ways, we distinguish between
   * "raw frames" and a "frame" which might be made up of multiple directions.
   *
   * On the subject of sprite sheet order: the divider may alter this, but in
   * general, frames are numbered left to right, top to bottom. If you have a 4
   * direction sprite sheet, then 0,1,2,3 will be frame 1, 4,5,6,7 will be 2,
   * and so on.
    */ 
   public class SpriteSheetComponent extends EntityComponent
   {
    /**
     * How many directions are there for each frame? If you have a normal 2D
     * sprite, there will be just one direction.
     */
    public var DirectionsPerFrame:Number = 1;

    public function get DegreesPerDirection():Number
    {
       return 360/DirectionsPerFrame;
    }

      public function get IsLoaded():Boolean
      {
         return ImageData != null;
      }
      
      public function get ImageFilename():String
      {
         return _image.Filename;
      }
      
      public function set ImageFilename(value:String):void
      {
         ResourceManager.Instance.Load(value, ImageResource, _OnImageLoaded);
      }
      
      public function get Image():ImageResource
      {
         return _image;
      }
      
      public function set Image(value:ImageResource):void
      {
         _frames = null;
         _image = value;
      }
      
    /**
     * Get the whole sprite sheet as a single image.
     */
      public function get ImageData():BitmapData
      {
         if (_image == null)
            return null;
         
         return _image.Image.bitmapData;
      }
      
      public function get Divider():ISpriteSheetDivider
      {
         return _divider;
      }
      
      public function set Divider(value:ISpriteSheetDivider):void
      {
         _divider = value;
         _divider.OwningSheet = this;
         _frames = null;
      }
      
    /**
     * Returns the count of actual frames from the image, the raw frame count.
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
     * Return a raw frame by index, ignoring any groupings like direction.
     */
      public function GetRawFrame(index:int):BitmapData
      {
         if (_frames == null)
            _BuildFrames();
         
         if (_frames == null)
            return null;
         
         if ((index < 0) || (index >= RawFrameCount))
            return null;
       
         return _frames[index];  
      }
      
      public function get FrameCount():int
      {
         return RawFrameCount / DirectionsPerFrame;
      }

      /**
       * Determine the correct BitmapData to display for a given direction and frame.
       * 
       * The closest match is returned.
       *
       * @param direction Heading in degrees. Can be < 0 or > 360.
       * @param index     Frame index.
       */      
      public function GetFrame(index:int, direction:Number = 0):BitmapData
      {
         // Easy case if we only have one direction per frame.
         if(DirectionsPerFrame == 1)
            return GetRawFrame(index);
         
         // Otherwise we have to do a search.
         // Make sure we have data to fulfill our requests from.
         if(_FrameNotes == null)
            _GenerateFrameNotes();
            
         // Unwrap the direction.
         while(direction > 360)
            direction -= 360;
         while(direction < 0)
            direction += 360;
         
         // Look for best match.
         var bestMatchIdx:int = -1;
         var bestMatchDirectionDist:Number = Number.POSITIVE_INFINITY;
         var bestMatchStateDist:int = int.MAX_VALUE;
         
         for(var i:int=0; i<_FrameNotes.length; i++)
         {
            var note:ViewNote = _FrameNotes[i] as ViewNote;
            
            if(Math.abs(note.Direction - direction) < bestMatchDirectionDist
               && (note.Frame - index) <= bestMatchStateDist
               && (note.Frame - index) >= 0)
            {
               // This one is better on both frame and heading.
               bestMatchDirectionDist = Math.abs(note.Direction - direction);
               bestMatchStateDist = note.Frame - index;
               bestMatchIdx = note.RawFrame;
            }
         }
         
         // Return the bitmap.
         return GetRawFrame(bestMatchIdx);
      }
      
      protected function _BuildFrames():void
      {
         if (ImageData == null)
            return;
         
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
      
      /**
       * Produce a lookup table describing what frames go with what states/headings.
       */ 
      private function _GenerateFrameNotes():void
      {
         _FrameNotes = new Array();
         
         var totalStates:int = RawFrameCount / DegreesPerDirection;
         
         for (var direction:int = 0; direction < DirectionsPerFrame; direction++)
         {
            for (var frame:int = 0; frame < FrameCount; frame++)
            {
               var note:ViewNote = new ViewNote();
               note.Frame = frame;
               note.Direction = direction * DegreesPerDirection;
               note.RawFrame = (direction * FrameCount) + frame;
               
               _FrameNotes.push(note);
            }
         }
      }
         
         private var _image:ImageResource = null;
      private var _divider:ISpriteSheetDivider = null;
      private var _frames:Array = null;
      private var _FrameNotes:Array;
   }
}

final class ViewNote
{
   public var Frame:int;
   public var Direction:Number;
   public var RawFrame:int;
}