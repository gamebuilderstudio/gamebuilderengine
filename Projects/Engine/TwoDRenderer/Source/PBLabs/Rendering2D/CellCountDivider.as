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
    * Divide a spritesheet into cells based on count - ie, 4 cells by 3 cells.
    */
   public class CellCountDivider implements ISpriteSheetDivider
   {
      /**
       * The number of cells in the x direction.
       */
      public var XCount:int = 1;
      
      /**
       * The number of cells in the y direction.
       */
      public var YCount:int = 1;
      
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
         return XCount * YCount;
      }
      
      /**
       * @inheritDoc
       */
      public function GetFrameArea(index:int):Rectangle
      {
         if (!_owningSheet)
            throw new Error("OwningSheet must be set before calling this!");

         var imageWidth:int = _owningSheet.ImageData.width;
         var imageHeight:int = _owningSheet.ImageData.height;
         
         var width:int = imageWidth / XCount;
         var height:int = imageHeight / YCount;
         
         var x:int = index % XCount;
         var y:int = Math.floor(index / XCount);
         
         var startX:int = x * width;
         var startY:int = y * height;
         
         return new Rectangle(startX, startY, width, height);
      }

      private var _owningSheet:SpriteSheetComponent;
   }
}