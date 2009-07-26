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
   import flash.geom.Rectangle;
   import com.pblabs.engine.debug.Logger;
   
  /**
   * Divide a sprite sheet into fixed-size cells.
   */
   public class FixedSizeDivider implements ISpriteSheetDivider
   {
      /**
       * The width of each frame.
       */
      [EditorData(defaultValue="32")]
      public var Width:int = 32;
      
      /**
       * The height of each frame.
       */
      [EditorData(defaultValue="32")]
      public var Height:int = 32;
      
      /**
       * @inheritDoc
       */
      [EditorData(ignore="true")]
      public function set owningSheet(value:SpriteSheetComponent):void
      {
         if(_owningSheet)
            Logger.printWarning(this, "set OwningSheet", "Already assigned to a sheet, reassigning may result in unexpected behavior.");
         _owningSheet = value;
      }
      
      public var _Garbage:Number;
      
      /**
       * @inheritDoc
       */
      public function get frameCount():int
      {
         if (!_owningSheet)
            throw new Error("OwningSheet must be set before calling this!");
         
         return Math.floor(_owningSheet.imageData.width / Width) * Math.floor(_owningSheet.imageData.height / Height);
      }
      
      /**
       * @inheritDoc
       */
      public function getFrameArea(index:int):Rectangle
      {
         if (!_owningSheet)
            throw new Error("OwningSheet must be set before calling this!");

         var x:int = index % Math.floor(_owningSheet.imageData.width / Width);
         var y:int = Math.floor(index / Math.floor(_owningSheet.imageData.width / Width));
         
         return new Rectangle(x * Width, y * Height, Width, Height);
      }
      
      /**
       * @inheritDoc
       */
      public function clone():ISpriteSheetDivider
      {
         var c:FixedSizeDivider = new FixedSizeDivider();
         c.Width = Width;
         c.Height = Height;
         return c;
      }

      private var _owningSheet:SpriteSheetComponent;
   }
}