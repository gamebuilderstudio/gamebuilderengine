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
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.engine.resource.ImageResource;
    import com.pblabs.engine.resource.ResourceManager;
    import com.pblabs.rendering2D.spritesheet.ISpriteSheet;
    
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
    public class BasicSpriteSheetComponent extends SpriteContainerComponent implements ISpriteSheet
    {
						
        /**
         * True if the image data associated with this sprite sheet has been loaded.
         */
        public override function get isLoaded():Boolean
        {
            return (imageData != null || _forcedBitmaps)
        }
        
        /**
         * The bitmap data of the loaded image.
         */
		[EditorData(ignore="true")]
        public function get imageData():BitmapData
        {
            return _imageData;
        }
		public function set imageData(data : BitmapData):void
		{
			_imageData = data;
			deleteFrames();
		}
        
        /**
         * The divider to use to chop up the sprite sheet into frames. If the divider
         * isn't set, the image will be treated as one whole frame.
         */
        [TypeHint(type="dynamic")]
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
            deleteFrames();
        }
		
        protected override function getSourceFrames() : Array
        {
            // If user provided their own bitmapdatas, return those.
            if(_forcedBitmaps)
                return _forcedBitmaps;
            
            var frames:Array;
            
            // image isn't loaded, can't do anything yet
            if (!imageData)
                return null;
            
            // no divider means treat the image as a single frame
            if (!_divider)
            {
                frames = new Array(1);
                frames[0] = imageData;
            }
            else
            {
                frames = new Array(_divider.frameCount);
								
                for (var i:int = 0; i < _divider.frameCount; i++)
                {
                    var area:Rectangle = _divider.getFrameArea(i);										
                    frames[i] = new BitmapData(area.width, area.height, true);
                    frames[i].copyPixels(imageData, area, new Point(0, 0));									
                }				
            }		
			
            return frames;
        }
        
        /**
         * From an array of BitmapDatas, initialize the sprite sheet, ignoring
         * divider + filename.
         */
        public function initializeFromBitmapDataArray(bitmaps:Array):void
        {
            _forcedBitmaps = bitmaps;
        }
		
		/**
		 * destory provides a mechanism to cleans up this component externally if not added to an 
		 * entity or internally when the onRemove method is called.
		 **/
		public function destroy():void
		{
			_imageData = null;
			if(_forcedBitmaps){
				var len : int = _forcedBitmaps.length;
				for(var i : int = 0; i < len; i++){
					_forcedBitmaps.pop();
				}
				_forcedBitmaps = null;
			}
			this.deleteFrames();
			if(_divider){
				_divider.owningSheet = null;
				_divider = null;
			}
		}
        
		protected override function onRemove():void
		{
			destroy();
			super.onRemove();         			
		}
		
		private var _imageData:BitmapData = null;
        private var _divider:ISpriteSheetDivider = null;
        private var _forcedBitmaps:Array = null;
    }
}
