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
    import com.pblabs.engine.resource.ResourceEvent;
    import com.pblabs.engine.resource.SWFResource;
    import com.pblabs.engine.util.ImageFrameData;
    import com.pblabs.engine.util.MCUtil;
    import com.pblabs.starling2D.spritesheet.SpriteContainerComponentG2D;
    
    import flash.display.BitmapData;
    import flash.display.MovieClip;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;

    /**
     * A class that is similar to the SpriteSheetComponent except the frames
     * are loaded by rasterizing frames from a MovieClip rather than splitting
     * a single image.
     */
    public class SWFSpriteSheetComponent extends SpriteContainerComponentG2D implements ISpriteSheet
    {
		
		public function SWFSpriteSheetComponent():void
		{
			super();
			_defaultCenter = false;
		}
		
		public function get isDestroyed():Boolean{ return _destroyed; }
		
        /**
         * When cached is set to true (the default) the rasterized frames
         * are re-used by all instances of the SWFSpriteSheetComponent
         * with the same values for swf, smoothing, and clipName.
         */
		public function get cached():Boolean { return _cached; }
		public function set cached(val : Boolean):void{
			if(_cached && !val)
			{
				var frameCache : CachedFramesData = getCachedFrames();
				if(frameCache){
					frameCache.referenceCount--;
					frameCache.released.remove(onCacheReleased);
				}
				releaseCache();
			}
			_cached = val;
			deleteFrames();
			buildFrames();
		}

        /**
         * The SWF to be rasterized into frames.
         */
        public function get swf():SWFResource
        {
            return _resource;
        }

        public function set swf(value:SWFResource):void
        {
			if(_resource)
				_resource.removeEventListener(ResourceEvent.UPDATED_EVENT, onResourceUpdated);
			if(_resource == value)
				return;
            _resource = value;
			_resource.addEventListener(ResourceEvent.UPDATED_EVENT, onResourceUpdated);
			
           if(frames)
				deleteFrames();
        }

        /**
         * The name of the clip to instantiate from the SWF.
         * If this is null the root clip will be used.
         */
        public function get clipName():String
        {
            return _clipName;
        }

        public function set clipName(value:String):void
        {
			if(_clipName == value)
				return;
            _clipName = value;
			if(frames)
				deleteFrames();
        }

        /**
         * The bounds of the source MovieClip.
         * This can be used for clips that are expected to be rendered based on their bounds.
         */
        public function get bounds():Rectangle
        {
            return _bounds ? _bounds.clone() : new Rectangle();
        }

        /**
         * Whether or not the bitmaps that are drawn should be smoothed. Default is True.
         */
        public function get smoothing():Boolean 
        {
            return _smoothing;
        }
        public function set smoothing(value:Boolean):void 
        {
            _smoothing = value;
        }

        /**
         * X/Y scaling for the SWF as it renders to bitmap.  
         * 
         * Value of (1, 1) mean no scaling (default).  
         * 
         * (0.5, 0.5) would be half the normal size, and (2, 2) would be double.
         */
        public function get scale():Point
        {
            return _scale.clone();
        }
        public function set scale(value:Point):void
        {
			if(!value || _scale.equals(value))
				return;
			
			if(value.x < .1) value.x = .1;
			if(value.y < .1) value.y = .1;
			var cacheKey : String = getFramesCacheKey();
			_scale.copyFrom( value );
			if(_cached){
				if(cacheKey in _frameCache){
					var cacheData:CachedFramesDataMC = _frameCache[cacheKey] as CachedFramesDataMC;
					delete _frameCache[cacheKey];
					cacheData.destroy();
				}
			}
			if(!_cached){
				deleteFrames();
				buildFrames();
			}
        }
        
        override public function get isLoaded() : Boolean
        {
            if (!_resource || !_resource.isLoaded || _resource.didFail) 
                return false;

            if (!frames) 
                buildFrames();

            return frames != null;
        }

		/**
		 * The bitmap data of the loaded image.
		 */
		[EditorData(ignore="true")]
		public function get imageData():BitmapData
		{
			return null;
		}
		public function set imageData(data : BitmapData):void
		{
			Logger.warn(this, "imageData", "You can not set raw image data on a swf spritesheet");
		}

		/**
		 * The divider to use to chop up the sprite sheet into frames. If the divider
		 * isn't set, the image will be treated as one whole frame.
		 */
		[EditorData(ignore="true")]
		[TypeHint(type="dynamic")]
		public function get divider():ISpriteSheetDivider
		{
			return null;
		}
		
		/**
		 * @private
		 */
		public function set divider(value:ISpriteSheetDivider):void
		{
			Logger.warn(this, "divider", "You can not set a divider on a swf spritesheet");
		}

		/**
		 * destroy provides a mechanism to cleans up this component externally if not added to an 
		 * entity or internally when the onRemove method is called.
		 **/
		public function destroy():void
		{
			if(_destroyed)
				return;
			
			if(_cached){
				var frameCache : CachedFramesData = getCachedFrames();
				
				if(frameCache && frameCache.referenceCount > 0){
					frameCache.referenceCount -= 1;
					frameCache.released.remove(onCacheReleased);
				}
				releaseCache();
			}else{
				var len : int = frames.length;
				for(var i : int = 0; i < len; i++)
				{
					frames[i].dispose();
				}
			}
			this.deleteFrames();

			if(_resource)
				_resource.removeEventListener(ResourceEvent.UPDATED_EVENT, onResourceUpdated);
			_resource = null;
			_bounds = null;
			_clip = null;
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

		override public function getFrame(index:int, direction:Number=0.0):BitmapData
		{
			var curframe : BitmapData = super.getFrame(index, direction);
			_center = _frameCenters[index];
			return curframe;
		}

		/**
         * Rasterizes the associated MovieClip and returns a list of frames.
         */
        override protected function getSourceFrames() : Array
        {
            if (!_resource || !_resource.isLoaded || _resource.didFail)
                return null;

            if (!frames)
                rasterize();

            return frames;
        }

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
            return _resource.filename + ":" + (clipName ? clipName : "_") + (_smoothing ? ":1" : ":0") + ":" + _scale.x + ":" +  _scale.y;
        }

		protected function onCacheReleased(cache : CachedFramesData):void
		{
			deleteFrames();
			if(this.owner)
				this.owner.reset();
		}
		
		protected function onResourceUpdated(event : ResourceEvent):void
		{
			if(_cached){
				releaseCache(false);
			}
			deleteFrames();
			buildFrames();
			if(owner)
				owner.reset();
		}

		/**
         * Rasterizes the clip into an Array of BitmapData objects.
         * This array can then be used just like a sprite sheet.
         */
        protected function rasterize():void
        {
            if (!_resource || !_resource.isLoaded || _resource.didFail) 
				return;

            var cacheData:CachedFramesDataMC = getCachedFrames() as CachedFramesDataMC;
            if (_cached && cacheData)
            {
				cacheData.released.addOnce(onCacheReleased);
				cacheData.referenceCount += 1;
				frames = cacheData.frames;
                _frameCenters = cacheData.frameCenters;
                _bounds = cacheData.bounds;
                _clip = cacheData.clip;
				_scale = cacheData.scale;
                return;
            } else {
				_bounds = null;
			}

			_clip = getMovieClip();
			if(!_clip)
				return;
            frames = onRasterize(_clip);
			_center = new Point(-_bounds.x, -_bounds.y);
			
			if(_cached){
				var frameCache : CachedFramesDataMC = new CachedFramesDataMC(frames, _bounds, _clip, _frameCenters, _scale);
				frameCache.released.addOnce(onCacheReleased);
				frameCache.referenceCount += 1;
				setCachedFrames(frameCache);
			}
        }
		
		protected function getMovieClip():MovieClip
		{
			if(!_resource)
				return null;
			var clip : MovieClip;
			if (_clipName)
			{
				clip = _resource.getExportedAsset(_clipName) as MovieClip;
				if (!clip)
					clip = _resource.clip;
			}
			else
			{
				clip = _resource.clip;
			}
			return clip;
		}

        /**
         * Performs the actual rasterizing. Override this to perform custom rasterizing of a clip.
         */
        protected function onRasterize(mc:MovieClip):Array
        {
            var maxFrames:int = mc.totalFrames;
            var rasterized:Array = new Array(maxFrames);
			_frameCenters = new Array(maxFrames);

			//Hack required so that the movie clip animation is drawn correctly
			//Ridiculous Adobe!!!
			if(PBE.mainStage){
				PBE.mainStage.addChild(mc);
			}
			
			var tmpBounds : Rectangle;
            if (maxFrames > 0){
				
				mc.gotoAndStop(1);
				swf.advanceChildClips(mc, 1);
				
				//Get overall bounds
				for(var i : int = 1; i <= maxFrames; i++)
				{
					if (mc.totalFrames >= i)
						mc.gotoAndStop(i);
					
					if(!_bounds)
						_bounds = MCUtil.getRealBounds(mc);
					else
						_bounds = _bounds.union(MCUtil.getRealBounds(mc));
				}
				//Reset MC
				mc.gotoAndStop(1);
				//Rasterize all the frames
				for(i = 1; i <= maxFrames; i++)
				{
					rasterized[i-1] = rasterizeFrame(mc, i);
				}
			}
			
			//Clean up hack
			if(PBE.mainStage && PBE.mainStage.contains(mc)){
				PBE.mainStage.removeChild(mc);
			}

            return rasterized;
        }

        protected function rasterizeFrame(mc:MovieClip, frameIndex:int):BitmapData
        {
            if (mc.totalFrames >= frameIndex)
                mc.gotoAndStop(frameIndex);

			var frameData : ImageFrameData = MCUtil.getBitmapDataByDisplay(mc, _scale, mc.transform.colorTransform, _bounds);
			_frameCenters[frameIndex-1] = new Point(-(frameData.bounds.x*_scale.x), -(frameData.bounds.y*_scale.y));
			var bd:BitmapData = frameData.bitmapData;
            return bd;
        }

		override protected function onAdd():void
		{
			super.onAdd();
			_destroyed = false;
			if(!frames)
				buildFrames();
		}
		
		override protected function onRemove():void
		{
			destroy();
			super.onRemove();         			
		}

		protected static var _frameCache:Dictionary = new Dictionary(true);

		protected var _smoothing:Boolean = true;
		protected var _scale:Point = new Point(1, 1);
		protected var _frameCenters:Array;
		protected var _resource:SWFResource;
		protected var _clipName:String;
		protected var _clip:MovieClip;
		protected var _bounds:Rectangle;
		protected var _cached:Boolean = true;
		protected var _destroyed : Boolean = false;
    }
}

