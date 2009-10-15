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
    import com.pblabs.engine.debug.Logger;
    
    import flash.geom.Rectangle;
    
    /**
     * Divide a sprite sheet into fixed-size cells.
     */
    public class FixedSizeDivider implements ISpriteSheetDivider
    {
        /**
         * The width of each frame.
         */
        [EditorData(defaultValue="32")]
        public var width:int = 32;
        
        /**
         * The height of each frame.
         */
        [EditorData(defaultValue="32")]
        public var height:int = 32;
        
        /**
         * The horizonal spacing between frames
         */	  
        [EditorData(defaultValue="0")]
        public var horizontalSpacing:int = 0;
        
        /**
         * The vertical spacing between frames
         */	  
        [EditorData(defaultValue="0")]
        public var verticalSpacing:int = 0;
        
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
            if (!_owningSheet)
                throw new Error("OwningSheet must be set before calling this!");
            
            return Math.floor(_owningSheet.imageData.width / width) * Math.floor(_owningSheet.imageData.height / height);
        }
        
        /**
         * @inheritDoc
         */
        public function getFrameArea(index:int):Rectangle
        {
            if (!_owningSheet)
                throw new Error("OwningSheet must be set before calling this!");
            
            var x:int = index % Math.floor(_owningSheet.imageData.width / width);
            var y:int = Math.floor(index / Math.floor(_owningSheet.imageData.width / width));
            
            return new Rectangle(x * (width + horizontalSpacing), y * (height + verticalSpacing), width, height);
        }
        
        /**
         * @inheritDoc
         */
        public function clone():ISpriteSheetDivider
        {
            var c:FixedSizeDivider = new FixedSizeDivider();
            c.width = width;
            c.height = height;
            return c;
        }
        
        private var _owningSheet:SpriteSheetComponent;
    }
}