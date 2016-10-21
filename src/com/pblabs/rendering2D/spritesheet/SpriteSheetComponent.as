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
    import com.pblabs.starling2D.spritesheet.SpriteContainerComponentG2D;
    
    import flash.display.BitmapData;
    import flash.geom.Matrix;
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
    public class SpriteSheetComponent extends SpriteContainerComponentG2D implements IImageSpriteSheet
    {
						
		public function get isDestroyed():Boolean{ return _destroyed; }
		/**
		 * When cached is set to true (the default) the rasterized frames
		 * are re-used by all instances of the SpriteSheetComponent
		 * with the same filename.
		 */
		public function get cached():Boolean { return _cached; }
		public function set cached(val : Boolean):void{
			if(_cached && !val && this.isLoaded)
			{
				var frameCache : CachedFramesData = getCachedFrames();
				if(frameCache){
					frameCache.referenceCount--;
					frameCache.released.remove(onCacheReleased);
				}
				releaseCache();
				deleteFrames();
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
					onImageLoaded(resource as ImageResource);
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
			if(_image)
			{
				if(_cached){
					var frameCache : CachedFramesData = getCachedFrames();
					if(frameCache){
						frameCache.referenceCount--;
						frameCache.released.remove(onCacheReleased);
					}
				}
				_image.removeEventListener(ResourceEvent.UPDATED_EVENT, onResourceUpdated);
			}
			
			if(value){
				_loaded = value.isLoaded;
				if(!_loaded){
					value.addEventListener(ResourceEvent.LOADED_EVENT, onResourceLoaded);
					value.addEventListener(ResourceEvent.FAILED_EVENT, onResourceLoadFailed);
					_imageAsynchLoadListenersAttached = true;
					_loading = true;
					return;
				}
			}
			_failed = false;
			
			_image = value;

			deleteFrames();
			if(_image){
				if(_imageAsynchLoadListenersAttached){
					_image.removeEventListener(ResourceEvent.LOADED_EVENT, onResourceLoaded);
					_image.removeEventListener(ResourceEvent.FAILED_EVENT, onResourceLoadFailed);
					_imageAsynchLoadListenersAttached = false;
				}
				_image.addEventListener(ResourceEvent.UPDATED_EVENT, onResourceUpdated);
				_imageFilename = _image.filename;
				buildFrames();
			}
		}
		
		/**
         * True if the image data associated with this sprite sheet has been loaded.
         */
        public override function get isLoaded():Boolean
        {
            var _loaded : Boolean = ((imageData != null || _forcedBitmaps) && _divider != null);
			if(_loaded && !frames)
				buildFrames();
			return _loaded;
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
			buildFrames();
        }
		
        protected override function getSourceFrames() : Array
        {
            // If user provided their own bitmapdatas, return those.
            if(_forcedBitmaps)
                return _forcedBitmaps;
            
            var _frames:Array;
            
			if(!imageData || !_image.bitmapData || !_divider || (_divider && (_divider is ISpriteSheetNamedFramesDivider) && !(_divider as ISpriteSheetNamedFramesDivider).isLoaded) || (_divider && _divider.frameCount == 0))
				return null;
            // image isn't loaded, can't do anything yet
            
			var cachedFrames : CachedFramesData = getCachedFrames();
			if (_cached && cachedFrames)
			{
				cachedFrames.released.add(onCacheReleased);
				cachedFrames.referenceCount += 1;
				_divider = cachedFrames.divider ? cachedFrames.divider.copy(_divider) : _divider;
				_bounds = cachedFrames.bounds ? cachedFrames.bounds : _bounds;
				return cachedFrames.frames;
			}

			// no divider means treat the image as a single frame
			_frames = new Array(_divider.frameCount);
			var tmpBounds : Rectangle;
            for (var i:int = 0; i < _divider.frameCount; i++)
            {
                var area:Rectangle = _divider.getFrameArea(i);										
				var isRotated : Boolean = false;
				if(_divider is ISpriteSheetNamedFramesDivider){
					isRotated = (_divider as ISpriteSheetNamedFramesDivider).isFrameAreaRotated(i);
				}
				var frameBitmapData : BitmapData = new BitmapData(area.width, area.height, true, 0x0);
				frameBitmapData.copyPixels(imageData, area, new Point(0, 0));

				if(isRotated){
					var rotatedBitmapData : BitmapData = new BitmapData(area.height, area.width, true, 0x0);
					var matrix:Matrix = new Matrix();
					matrix.rotate( -90 * Math.PI / 180 );
					matrix.translate(0, frameBitmapData.width);
					rotatedBitmapData.draw(frameBitmapData, matrix);
					frameBitmapData.dispose();
					frameBitmapData = rotatedBitmapData;
				}

				tmpBounds = new Rectangle(0,0,frameBitmapData.width, frameBitmapData.height);
				_frames[i] = frameBitmapData;
				
				if(!_bounds){
					_bounds = tmpBounds.clone();
				}else{
					var difX : Number = PBUtil.clamp( tmpBounds.width - _bounds.width, 0, 99999999);
					var difY : Number = PBUtil.clamp( tmpBounds.height - _bounds.height, 0, 99999999);
					_bounds.inflate(difX, difY);
				}

            }				

			if(_cached){
				var frameCache : CachedFramesData = new CachedFramesData(_frames, imageFilename, _divider, _bounds);
				frameCache.released.add(onCacheReleased);
				frameCache.referenceCount += 1;
				setCachedFrames(frameCache);
			}
			
            return _frames;
        }
        
		private function rotateBitmapData( bitmapData:BitmapData, degree:int = 0 ) :BitmapData
		{
			var newBitmap:BitmapData = new BitmapData( bitmapData.height, bitmapData.width, true, 0x0 );
			var matrix:Matrix = new Matrix();
			matrix.rotate( degree * Math.PI / 180 );
			
			if ( degree == 90 ) {
				matrix.translate( bitmapData.height, 0 );
			} else if ( degree == -90 || degree == 270 ) {
				matrix.translate( 0, bitmapData.width );
			} else if ( degree == 180 ) {
				newBitmap = new BitmapData( bitmapData.width, bitmapData.height, true, 0x0 );
				matrix.translate( bitmapData.width, bitmapData.height );
			}
			
			newBitmap.draw( bitmapData, matrix, null, null, null, true )
			return newBitmap;
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
					frameCache.referenceCount--;
					frameCache.released.remove(onCacheReleased);
				}else{
					releaseCache();
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
			}
		
			this.deleteFrames();
			
			if(_divider){
				if(!_cached || (_cached && frameCache.divider != _divider))
					_divider.destroy();
			}
			_divider = null;
			_bounds = null;

			if(_imageData) _imageData = null;

			if(_image){
				_image.removeEventListener(ResourceEvent.UPDATED_EVENT, onResourceUpdated);
			}
			image = null;
			_loaded = false;
			_destroyed = true;
		}
		
		public function releaseCache(checkReferenceCount : Boolean = true):void
		{
			var frameCache : CachedFramesData = getCachedFrames();
			if(!frameCache || (checkReferenceCount && frameCache && frameCache.referenceCount > 0)){
				return;
			}
			delete _frameCache[getFramesCacheKey()];
			frameCache.released.remove(onCacheReleased);
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
			if (!_image && _imageFilename!=null && _imageFilename!="" && !loading)
			{
				_loading = true;
				var resource : ImageResource = PBE.resourceManager.load(imageFilename, ImageResource, onImageLoaded, onImageFailed) as ImageResource;
				if(resource && resource.isLoaded)
					onImageLoaded(resource);
			}
			_destroyed = false;
		}
		
		override protected function onRemove():void
		{
			destroy();
			super.onRemove();         			
		}
		
		override protected function buildFrames():void
		{
			if(!_divider && (!_cached || (_cached && !getCachedFrames()) )) return;
			
			super.buildFrames();
		}
		
		protected function onResourceUpdated(event : ResourceEvent):void
		{
			if(cached)
				releaseCache(false);
			onImageLoaded(event.resourceObject as ImageResource);
			buildFrames();
			if(this.owner)
				this.owner.reset();
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
			if (!_cached || !getFramesCacheKey()) 
				return null;
			
			return _frameCache[getFramesCacheKey()] as CachedFramesData;
		}
		
		/**
		 * Caches the frames based on the current values.
		 */
		protected function setCachedFrames(frames:CachedFramesData):void 
		{
			if (!_cached || !getFramesCacheKey()) 
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
		protected var _cacheReleasePending:Boolean = false;
		protected var _imageAsynchLoadListenersAttached : Boolean = false;
    }
}