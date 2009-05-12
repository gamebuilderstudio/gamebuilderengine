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
   import PBLabs.Engine.Debug.Logger;
   
   /**
    * Divide a spritesheet into cells based on count - ie, 4 cells by 3 cells.
    */
   public class CellCountDivider implements ISpriteSheetDivider
   {
      /**
       * The number of cells in the x direction.
       */
      [EditorData(defaultValue="1")]
      public var XCount:int = 1;
      
      /**
       * The number of cells in the y direction.
       */
      [EditorData(defaultValue="1")]
      public var YCount:int = 1;
      
      /**
       * @inheritDoc
       */
      [EditorData(ignore="true")]
      public function set OwningSheet(value:SpriteSheetComponent):void
      {
         if(_owningSheet)
            Logger.PrintWarning(this, "set OwningSheet", "Already assigned to a sheet, reassigning may result in unexpected behavior.");
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

      /**
       * @inheritDoc
       */
      public function Clone():ISpriteSheetDivider
      {
         var c:CellCountDivider = new CellCountDivider();
         c.XCount = XCount;
         c.YCount = YCount;
         return c;
      }

      private var _owningSheet:SpriteSheetComponent;
   }
}