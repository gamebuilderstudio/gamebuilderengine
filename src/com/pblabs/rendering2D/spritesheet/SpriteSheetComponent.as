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
    public class SpriteSheetComponent extends BasicSpriteSheetComponent
    {
						
        [EditorData(ignore="true")]
        /**
         * The filename of the image to use for this sprite sheet.
         */
        public function get imageFilename():String
        {
            return _imageFilename;
        }
        
        /**
         * @private
         */
        public function set imageFilename(value:String):void
        {
			if (imageFilename!=value)
			{
	            if (_image)
	            {
	                PBE.resourceManager.unload(_image.filename, ImageResource);
	                image = null;
	            }
				_imageFilename = value;
	            _loading = true;
				// Tell the ResourceManager to load the ImageResource
	            PBE.resourceManager.load(value, ImageResource, onImageLoaded, onImageFailed);
			}
        }
		
		
		/**
		 * Indicates if the ImageResource loading is in progress 
		 */ 
		[EditorData(ignore="true")]
		public function get loading():Boolean
		{
			return _loading;
		}
		
		/**
		 * Indicates if the ImageResource has been loaded 
		 */ 
		[EditorData(ignore="true")]
		public function get loaded():Boolean
		{
			return _loaded;
		}
		
		/**
		 * Indicates if the ImageResource has failed loading 
		 */
		[EditorData(ignore="true")]
		public function get failed():Boolean
		{
			return _failed;
		}
		
        
        /**
         * The image resource to use for this sprite sheet.
         */
        public function get image():ImageResource
        {
            return _image;
        }
        
        /**
         * @private
         */
        public function set image(value:ImageResource):void
        {
			_loaded = true;
			_failed = false;

			_image = value;
			_imageFilename = _image.filename;
            deleteFrames();
        }
        
		[EditorData(ignore="true")]
        /**
         * The bitmap data of the loaded image.
         */
		override public function get imageData():BitmapData
        {
            if (!_image)
                return null;
            
            return _image.bitmapData;
        }
		override public function set imageData(val : BitmapData):void{
			Logger.warn(this, 'set imageData', 'You can not set the imageData on the SpriteSheetComponent, pass a fileName to be loaded.');
		}
        
        protected function onImageLoaded(resource:ImageResource):void
        {
			_loading = false;
            image = resource;
        }
        		
        protected function onImageFailed(resource:ImageResource):void
        {
			_loading = false;
			_failed = true;
            Logger.error(this, "onImageFailed", "Failed to load '" + (resource ? resource.filename : "(unknown)") + "'");
        }
		
		override protected function onAdd():void
		{
			super.onAdd();
			if (!_image && imageFilename!=null && imageFilename!="" && !loading)
			{
				_loading = true;
				PBE.resourceManager.load(imageFilename, ImageResource, onImageLoaded, onImageFailed);
			}
		}
		
		override protected function onRemove():void
		{
			if (_image)
			{
				PBE.resourceManager.unload(_image.filename, ImageResource);
				_image = null;
				_loaded = false;
			}  
			super.onRemove();         			
		}
		
        
		private var _imageFilename:String = null;
        private var _image:ImageResource = null;
		private var _loading:Boolean = false;
		private var _loaded:Boolean = false;
		private var _failed:Boolean = false;
    }
}
