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
   import flash.geom.Rectangle;
   
  /**
   * Divide a sprite sheet into fixed-size cells.
   */
   public class FixedSizeDivider implements ISpriteSheetDivider
   {
      /**
       * The width of each frame.
       */
      public var Width:int = 32;
      
      /**
       * The height of each frame.
       */
      public var Height:int = 32;
      
      /**
       * @inheritDoc
       */
      public function set OwningSheet(value:SpriteSheetComponent):void
      {
         _owningSheet = value;
      }
      
      /**
       * @inheritDoc
       */
      public function get FrameCount():int
      {
         if (!_owningSheet)
            throw new Error("OwningSheet must be set before calling this!");
         
         return Math.floor(_owningSheet.ImageData.width / Width) * Math.floor(_owningSheet.ImageData.height / Height);
      }
      
      /**
       * @inheritDoc
       */
      public function GetFrameArea(index:int):Rectangle
      {
         if (!_owningSheet)
            throw new Error("OwningSheet must be set before calling this!");

         var x:int = index % Math.floor(_owningSheet.ImageData.width / Width);
         var y:int = Math.floor(index / Math.floor(_owningSheet.ImageData.width / Width));
         
         return new Rectangle(x * Width, y * Height, Width, Height);
      }

      private var _owningSheet:SpriteSheetComponent;
   }
}