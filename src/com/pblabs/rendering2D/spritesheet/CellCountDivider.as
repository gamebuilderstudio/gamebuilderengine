/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.rendering2D.spritesheet
{
    import flash.geom.Rectangle;
    import com.pblabs.engine.debug.Logger;
    
    /**
     * Divide a spritesheet into cells based on count - ie, 4 cells by 3 cells.
     */
    public class CellCountDivider implements ISpriteSheetDivider
    {
        /**
         * The number of cells in the x direction.
         */
        [EditorData(defaultValue="1")]
        public var xCount:int = 1;
        
        /**
         * The number of cells in the y direction.
         */
        [EditorData(defaultValue="1")]
        public var yCount:int = 1;
        
        /**
         * @inheritDoc
         */
        [EditorData(ignore="true")]
        public function set owningSheet(value:SpriteSheetComponent):void
        {
            if(_owningSheet)
                Logger.warn(this, "set OwningSheet", "Already assigned to a sheet, reassigning may result in unexpected behavior.");
            _owningSheet = value;
        }
        
        /**
         * @inheritDoc
         */
        public function get frameCount():int
        {
            return xCount * yCount;
        }
        
        /**
         * @inheritDoc
         */
        public function getFrameArea(index:int):Rectangle
        {
            if (!_owningSheet)
                throw new Error("OwningSheet must be set before calling this!");
            
            var imageWidth:int = _owningSheet.imageData.width;
            var imageHeight:int = _owningSheet.imageData.height;
            
            var width:int = imageWidth / xCount;
            var height:int = imageHeight / yCount;
            
            var x:int = index % xCount;
            var y:int = Math.floor(index / xCount);
            
            var startX:int = x * width;
            var startY:int = y * height;
            
            return new Rectangle(startX, startY, width, height);
        }
        
        /**
         * @inheritDoc
         */
        public function clone():ISpriteSheetDivider
        {
            var c:CellCountDivider = new CellCountDivider();
            c.xCount = xCount;
            c.yCount = yCount;
            return c;
        }
        
        private var _owningSheet:SpriteSheetComponent;
    }
}