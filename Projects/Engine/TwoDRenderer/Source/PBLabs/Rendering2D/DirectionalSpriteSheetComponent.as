package PBLabs.Rendering2D
{
   import flash.display.BitmapData;
   
   /**
    * Extension to the SpriteSheetComponent that allows several directions to be
    * specified per frame. This allows a sprite to be displayed and animated with
    * several different viewpoints.
    * 
    * <p>Because we may group them in different ways, we distinguish between
    * "raw frames" and a "frame" which might be made up of multiple directions.</p>
    * 
    * <p>On the subject of sprite sheet order: the divider may alter this, but in
    * general, frames are numbered left to right, top to bottom. If you have a 4
    * direction sprite sheet, then 0,1,2,3 will be frame 1, 4,5,6,7 will be 2,
    * and so on.</p>
    */ 
   public class DirectionalSpriteSheetComponent extends SpriteSheetComponent
   {
      /**
       * The number of directions per frame.
       */
      public var DirectionsPerFrame:Number = 1;
      
      /**
       * The direction to use when retrieving frames. Values are automatically normalized
       * between 0 and 360.
       */
      public function get Direction():Number
      {
         return _currentDirection;
      }
      
      /**
       * @private
       */
      public function set Direction(value:Number):void
      {
         while (value < 0)
            value += 360;
         
         while (value > 360)
            value -= 360;
         
         _currentDirection = value;
      }
      
      /**
       * The number of degrees separating each direction.
       */
      public function get DegreesPerDirection():Number
      {
         return 360 / DirectionsPerFrame;
      }
      
      /**
       * The number of frames. This only counts one for each set of directions.
       */
      public override function get FrameCount():int
      {
         return super.FrameCount / DirectionsPerFrame;
      }
      
      /**
       * This uses the currently set Direction value to determine which version of the frame
       * to grab. It is based on a closest match, so the direction value does not have to be
       * exact.
       * 
       * @inheritDoc
       */
      public override function GetFrame(index:int):BitmapData
      {
         // Easy case if we only have one direction per frame.
         if (DirectionsPerFrame == 1)
            return super.GetFrame(index);
         
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
            
            if (Math.abs(note.Direction - _currentDirection) < bestMatchDirectionDistance)
            {
               // This one is better on both frame and heading.
               bestMatchDirectionDistance = Math.abs(note.Direction - _currentDirection);
               bestMatchIndex = note.RawFrame;
            }
         }
         
         // Return the bitmap.
         if (bestMatchIndex >= 0)
            return GetFrame(bestMatchIndex);
         
         return null;
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
      private var _currentDirection:Number = 0.0;
   }
}

final class FrameNote
{
   public var Frame:int;
   public var Direction:Number;
   public var RawFrame:int;
}