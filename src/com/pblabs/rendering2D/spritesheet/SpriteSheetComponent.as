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
    import com.pblabs.engine.PBUtil;
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.engine.resource.ImageResource;
    import com.pblabs.engine.resource.Resource;
    import com.pblabs.engine.resource.ResourceEvent;
    import com.pblabs.rendering2D.spritesheet.ISpriteSheet;
    import com.pblabs.starling2D.spritesheet.SpriteContainerComponentG2D;
    
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
    public class SpriteSheetComponent extends SpriteContainerComponentG2D implements ISpriteSheet
    {
						
		public function get isDestroyed():Boolean{ return _destroyed; }
		/**
		 * When cached is set to true (the default) the rasterized frames
		 * are re-used by all instances of the SpriteSheetComponent
		 * with the same filename.
		 */
		public function get cached():Boolean { return _cached; }
		public function set cached(val : Boolean):void{
			if(_cached && !val)
			{
				var frameCache : CachedFramesData = getCachedFrames();
				if(frameCache)
					frameCache.released.remove(onCacheReleased);
			}
			_cached = val;
		}

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
			if(!value)
				return;
			
			_loaded = value.isLoaded;
			if(!_loaded){
				value.addEventListener(ResourceEvent.LOADED_EVENT, onResourceLoaded);
				_loading = true;
			}
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
		 * The bounds of the largest frame in the spritesheet
		 */
		public function get bounds():Rectangle
		{
			if(!_bounds)
				return new Rectangle();
			return _bounds.clone();
		}

		/**
         * @private
         */
        public function set divider(value:ISpriteSheetDivider):void
        {
            _divider = value;
			if(_divider)
            	_divider.owningSheet = this;
			if(_cached){
				var cachedFrames : CachedFramesData = getCachedFrames();
				if(cachedFrames)
					_divider.copy( cachedFrames.divider ); 
			}
				
            deleteFrames();
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
			if (_cached && cachedFrames)
			{
				cachedFrames.released.addOnce(onCacheReleased);
				cachedFrames.referenceCount += 1;
				if(_divider)
					cachedFrames.divider.copy( _divider );
				_bounds = cachedFrames.bounds ? cachedFrames.bounds : _bounds;
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
				var tmpBounds : Rectangle;
                for (var i:int = 0; i < _divider.frameCount; i++)
                {
                    var area:Rectangle = _divider.getFrameArea(i);										
					_frames[i] = new BitmapData(area.width, area.height, true);
					_frames[i].copyPixels(imageData, area, new Point(0, 0));
					tmpBounds = new Rectangle(0,0,_frames[i].width, _frames[i].height);
					if(!_bounds){
						_bounds = tmpBounds;
					}else{
						var difX : Number = PBUtil.clamp( tmpBounds.width - _bounds.width, 0, 99999999);
						var difY : Number = PBUtil.clamp( tmpBounds.height - _bounds.height, 0, 99999999);
						_bounds.inflate(difX, difY);
					}

                }				
            }		
			
			if(_cached){
				var frameCache : CachedFramesData = new CachedFramesData(_frames, imageFilename, _divider, _bounds);
				frameCache.released.addOnce(onCacheReleased);
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
			if(_destroyed) return;
			
			if(_cached){
				var frameCache : CachedFramesData = getCachedFrames();
				
				if(frameCache && frameCache.referenceCount > 0){
					frameCache.referenceCount -= 1;
					frameCache.released.remove(onCacheReleased);
				}
				if(_divider){
					_divider.destroy();
				}
			}else{
				var len : int = frames.length;
				for(var i : int = 0; i < len; i++)
				{
					frames[i].dispose();
				}
				//TODO: Add clearing cache handling here
				if(_forcedBitmaps){
					len = _forcedBitmaps.length;
					for(i = 0; i < len; i++){
						//We don't clean up the bitmaps in the forced bitmaps array 
						//because the bitmaps were created elsewhere
						_forcedBitmaps.pop();
					}
					_forcedBitmaps = null;
				}
				if(_divider){
					_divider.destroy();
				}
			}
		
			this.deleteFrames();
			
			_divider = null;
			_bounds = null;
			//TODO Add reference count check here to decide if we want to delete cache
			/*if(getCachedFrames() && getCachedFrames().referenceCount <= 0){
				Logger.print(this, "Deleting SpriteSheet With Key ["+getFramesCacheKey()+"]");
			}*/

			if(_imageData) _imageData = null;
			image = null;
			
			_destroyed = true;
		}
		
		public function releaseCache(checkReferenceCount : Boolean = true):void
		{
			var frameCache : CachedFramesData = getCachedFrames();
			if(!frameCache || (checkReferenceCount && frameCache && frameCache.referenceCount > 0)){
				return;
			}
			delete _frameCache[getFramesCacheKey()];
			frameCache.destroy();
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
			_destroyed = false;
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
			if(!_divider && (!_cached || (_cached && !getCachedFrames()) )) return;
			
			super.buildFrames();
		}
		
		protected function onResourceLoaded(event : ResourceEvent):void
		{
			onImageLoaded(event.resourceObject as ImageResource);
		}
		protected function onResourceLoadFailed(event : ResourceEvent):void
		{
			onImageFailed(event.resourceObject as ImageResource);
		}
		/*--------------------------------------------------------------------------------------------*/
		//* Caching Functionality
		/*--------------------------------------------------------------------------------------------*/
		/**
		 * Reads the frames from the cache. Returns a null reference if they are not _cached.
		 */
		protected function getCachedFrames():CachedFramesData
		{
			if (!_cached) 
				return null;
			
			return _frameCache[getFramesCacheKey()] as CachedFramesData;
		}
		
		/**
		 * Caches the frames based on the current values.
		 */
		protected function setCachedFrames(frames:CachedFramesData):void 
		{
			if (!_cached) 
				return;
			_frameCache[getFramesCacheKey()] = frames;
		}
		
		protected function getFramesCacheKey():String
		{
			return imageFilename;
		}

		protected function onCacheReleased(cache : CachedFramesData):void
		{
			deleteFrames();
			if(this.owner)
				this.owner.reset();
		}

		protected static var _frameCache:Dictionary = new Dictionary(true);

		protected var _imageFilename:String = null;
		protected var _image:ImageResource = null;
		protected var _loading:Boolean = false;
		protected var _loaded:Boolean = false;
		protected var _failed:Boolean = false;
		protected var _imageData:BitmapData = null;
		protected var _divider:ISpriteSheetDivider = null;
		protected var _bounds:Rectangle;
		protected var _forcedBitmaps:Array = null;
		protected var _destroyed:Boolean = false;
		protected var _cached:Boolean = true;
    }
}