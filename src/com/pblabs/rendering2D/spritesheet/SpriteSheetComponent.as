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
    import com.pblabs.engine.resource.Resource;
    import com.pblabs.engine.resource.ResourceManager;
    import com.pblabs.rendering2D.spritesheet.ISpriteSheet;
    
    import flash.display.BitmapData;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    
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
    public class SpriteSheetComponent extends SpriteContainerComponent implements ISpriteSheet
    {
						
		/**
		 * When cached is set to true (the default) the rasterized frames
		 * are re-used by all instances of the SpriteSheetComponent
		 * with the same filename.
		 */
		public var cached:Boolean = true;

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
					//PBE.resourceManager.unload(_image.filename, ImageResource);
					image = null;
				}
				_imageFilename = value;
				_loading = true;
				// Tell the ResourceManager to load the ImageResource
				var resource : Resource = PBE.resourceManager.load(value, ImageResource, onImageLoaded, onImageFailed);
				if(resource && resource.isLoaded)
					image = resource as ImageResource;
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
			_loaded = value ? true : false;
			_failed = false;
			
			_image = value;
			if(_image) _imageFilename = _image.filename;
			deleteFrames();
		}
		
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
			if (!_image)
				return _imageData;
			
			return _image.bitmapData;
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
		
		protected override function deleteFrames():void
		{
			super.deleteFrames();	
		}
		
        protected override function getSourceFrames() : Array
        {
            // If user provided their own bitmapdatas, return those.
            if(_forcedBitmaps)
                return _forcedBitmaps;
            
            var _frames:Array;
            
            // image isn't loaded, can't do anything yet
            if (!imageData)
                return null;
            
			var cachedFrames : CachedFramesData = getCachedFrames();
			if (cached && cachedFrames)
			{
				cachedFrames.referenceCount += 1;
				_divider = cachedFrames.divider ? cachedFrames.divider : _divider;
				return cachedFrames.frames;
			}

			// no divider means treat the image as a single frame
            if (!_divider)
            {
				_frames = new Array(1);
				_frames[0] = imageData.clone();
            }
            else
            {
				_frames = new Array(_divider.frameCount);
								
                for (var i:int = 0; i < _divider.frameCount; i++)
                {
                    var area:Rectangle = _divider.getFrameArea(i);										
					_frames[i] = new BitmapData(area.width, area.height, true);
					_frames[i].copyPixels(imageData, area, new Point(0, 0));									
                }				
            }		
			
			if(cached){
				var frameCache : CachedFramesData = new CachedFramesData(_frames, imageFilename, _divider);
				frameCache.referenceCount += 1;
				setCachedFrames(frameCache);
			}
            return _frames;
        }
        
        /**
         * From an array of BitmapDatas, initialize the sprite sheet, ignoring
         * divider + filename.
         */
        public function initializeFromBitmapDataArray(bitmaps:Array):void
        {
			//TODO: Add Caching Handling Herer
            _forcedBitmaps = bitmaps;
        }
		
		/**
		 * destory provides a mechanism to cleans up this component externally if not added to an 
		 * entity or internally when the onRemove method is called.
		 **/
		public function destroy():void
		{
			//TODO: Add clearing cache handling here
			if(_forcedBitmaps){
				var len : int = _forcedBitmaps.length;
				for(var i : int = 0; i < len; i++){
					_forcedBitmaps.pop();
				}
				_forcedBitmaps = null;
			}
			this.deleteFrames();
			
			if(getCachedFrames() && getCachedFrames().referenceCount != 0){
				getCachedFrames().referenceCount -= 1;
			}

			if(cached && getCachedFrames() && getCachedFrames().referenceCount <= 0){
				getCachedFrames().destroy();
				delete _frameCache[getFramesCacheKey()];
				//Divider is cleaned up in the CachedFramesData.destroy()
			}else{
				if(_divider){
					_divider.destroy();
					_divider.owningSheet = null;
					_divider = null;
				}
			}
			//TODO Add reference count check here to decide if we want to delete cache
			/*if(getCachedFrames() && getCachedFrames().referenceCount <= 0){
				Logger.print(this, "Deleting SpriteSheet With Key ["+getFramesCacheKey()+"]");
			}*/

			if(_imageData) _imageData = null;
			image = null;
			
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
				//PBE.resourceManager.unload(_image.filename, ImageResource);
				_image = null;
				_loaded = false;
			}  
			destroy();
			super.onRemove();         			
		}
		
		override protected function buildFrames():void
		{
			if(!_divider) return;
			
			super.buildFrames();
		}
		
		/*--------------------------------------------------------------------------------------------*/
		//* Caching Functionality
		/*--------------------------------------------------------------------------------------------*/
		/**
		 * Reads the frames from the cache. Returns a null reference if they are not cached.
		 */
		protected function getCachedFrames():CachedFramesData
		{
			if (!cached) 
				return null;
			
			return _frameCache[getFramesCacheKey()] as CachedFramesData;
		}
		
		/**
		 * Caches the frames based on the current values.
		 */
		protected function setCachedFrames(frames:CachedFramesData):void 
		{
			if (!cached) 
				return;
			_frameCache[getFramesCacheKey()] = frames;
		}
		
		protected function getFramesCacheKey():String
		{
			return imageFilename;
		}


		protected static var _frameCache:Dictionary = new Dictionary(true);

		private var _imageFilename:String = null;
		private var _image:ImageResource = null;
		private var _loading:Boolean = false;
		private var _loaded:Boolean = false;
		private var _failed:Boolean = false;
		private var _imageData:BitmapData = null;
        private var _divider:ISpriteSheetDivider = null;
        private var _forcedBitmaps:Array = null;
    }
}
import com.pblabs.rendering2D.spritesheet.ISpriteSheetDivider;

final class CachedFramesData
{
	public function CachedFramesData(frames:Array, fileName : String, divider : ISpriteSheetDivider )
	{
		this.frames = frames;
		this.fileName = fileName;
		this.divider = divider;
	}
	public var frames:Array;
	public var fileName:String;
	public var divider:ISpriteSheetDivider;
	public var referenceCount : int = 0;
	
	public function destroy():void
	{
		if(frames){
			while(frames.length > 0)
			{
				frames[0].dispose();
				frames.splice(0,1);
			}
		}
		frames = null;
		if(divider){
			divider.destroy();
			divider = null;
		}
	}
}