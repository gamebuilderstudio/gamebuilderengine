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
    import com.pblabs.engine.PBUtil;
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.engine.resource.SWFResource;
    import com.pblabs.starling2D.spritesheet.SpriteContainerComponentG2D;
    
    import flash.display.*;
    import flash.geom.*;
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
        /**
         * When cached is set to true (the default) the rasterized frames
         * are re-used by all instances of the SWFSpriteSheetComponent
         * with the same values for swf, smoothing, and clipName.
         */
        public var cached:Boolean = true;

        /**
         * The SWF to be rasterized into frames.
         */
        public function get swf():SWFResource
        {
            return _resource;
        }

        public function set swf(value:SWFResource):void
        {
            _resource = value;
            frames = null;
            _clip = null;
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
            _clipName = value;
            frames = null;
            _clip = null;
            deleteFrames();
        }

        /**
         * The bounds of the source MovieClip.
         * This can be used for clips that are expected to be rendered based on their bounds.
         */
        public function get bounds():Rectangle
        {
            return _bounds.clone();
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
			var newScale : Boolean = false;
			if(!value.equals( _scale ))
				newScale = true;
			if(value.x < .1) value.x = .1;
			if(value.y < .1) value.y = .1;
			
            _scale = value.clone();
			if(newScale){
				this.deleteFrames();
				getCachedFrames().destroy();
				delete _frameCache[getFramesCacheKey()];
			}
        }
        
        override public function get isLoaded() : Boolean
        {
            if (!_resource || !_resource.isLoaded) 
                return false;

            if (!frames) 
                rasterize();

            return frames != null;
        }

		/**
		 * The bitmap data of the loaded image.
		 */
		[EditorData(ignore="true")]
		public function get imageData():BitmapData
		{
			//Logger.warn(this, "imageData", "Image data is not available on a swf spritesheet");
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
			Logger.warn(this, "divider", "There is no divider on a swf spritesheet");
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
			if(cached){
				var frameCache : CachedFramesData = getCachedFrames();
				
				if(frameCache && frameCache.referenceCount > 0){
					frameCache.referenceCount -= 1;
				}
				if(frameCache && frameCache.referenceCount <= 0){
					frameCache.destroy();
					delete _frameCache[getFramesCacheKey()];
				}
			}else{
				var len : int = frames.length;
				for(var i : int = 0; i < len; i++)
				{
					frames[i].dispose();
				}
			}
			this.deleteFrames();

			_resource = null;
			_bounds = null;
			_clip = null;
		}
		
		override protected function deleteFrames():void
		{
			super.deleteFrames();
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
            if (!_resource || !_resource.isLoaded)
                return null;

            if (!frames)
                rasterize();

            return frames;
        }

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
            return _resource.filename + ":" + (clipName ? clipName : "") + (_smoothing ? ":1" : ":0");
        }

        /**
         * Rasterizes the clip into an Array of BitmapData objects.
         * This array can then be used just like a sprite sheet.
         */
        protected function rasterize():void
        {
            if (!_resource.isLoaded) return;

            var cache:CachedFramesDataMC = getCachedFrames() as CachedFramesDataMC;
            if (cache)
            {
				cache.referenceCount += 1;
				frames = cache.frames;
                _frameCenters = cache.frameCenters;
                _bounds = cache.bounds;
                _clip = cache.clip;
                return;
            } else {
				_bounds = null;
			}

            if (_clipName)
            {
                _clip = _resource.getExportedAsset(_clipName) as MovieClip;
                if (!_clip)
                    _clip = _resource.clip;
            }
            else
            {
                _clip = _resource.clip;
            }

            frames = onRasterize(_clip);
			_center = new Point(-_bounds.x, -_bounds.y);
			
			if(cached){
				var frameCache : CachedFramesDataMC = new CachedFramesDataMC(frames, _bounds, _clip, _frameCenters);
				frameCache.referenceCount += 1;
				setCachedFrames(frameCache);
			}
        }

        /**
         * Performs the actual rasterizing. Override this to perform custom rasterizing of a clip.
         */
        protected function onRasterize(mc:MovieClip):Array
        {
            var maxFrames:int = swf.findMaxFrames(mc, mc.totalFrames);
            var rasterized:Array = new Array(maxFrames);
			_frameCenters = new Array(maxFrames);

			// Scaling if needed (including filters)
			/*if (_scale.x != 1 || _scale.y != 1)
			{
				
				mc.scaleX *= _scale.x;
				mc.scaleY *= _scale.y;
				
				if (mc.filters.length > 0)
				{
					var filters:Array = mc.filters;
					var filtersLen:int = mc.filters.length;
					var filter:Object;
					for (var j:uint = 0; j < filtersLen; j++)
					{
						filter = filters[j];
						
						if (filter.hasOwnProperty("blurX"))
						{
							filter.blurX *= _scale.x;
							filter.blurY *= _scale.y;
						}
						if (filter.hasOwnProperty("distance"))
						{
							filter.distance *= (_scale.x+_scale.y)/2;
						}
					}
					mc.filters = filters;
				}
			}*/
			
			var tmpBounds : Rectangle;
            if (maxFrames > 0){
				//Get overall bounds
				for(var i : int = 1; i <= maxFrames; i++)
				{
					if (mc.totalFrames >= i)
						mc.gotoAndStop(i);
					
					swf.advanceChildClips(mc, i);
					
					if(!_bounds)
						_bounds = getRealBounds(mc);
					else
						_bounds = _bounds.union(getRealBounds(mc));
				}
				//Reset MC
				mc.gotoAndStop(0);
				swf.advanceChildClips(mc, 0);
				//Rasterize all the frames
				for(i = 1; i <= maxFrames; i++)
				{
					rasterized[i-1] = rasterizeFrame(mc, i);
				}
			}
			
            return rasterized;
        }

        protected function rasterizeFrame(mc:MovieClip, frameIndex:int):BitmapData
        {
            if (mc.totalFrames >= frameIndex)
                mc.gotoAndStop(frameIndex);

			swf.advanceChildClips(mc, frameIndex);

			var frameData : ImageFrameData = getBitmapDataByDisplay(mc, _scale, mc.transform.colorTransform, _bounds);
			_frameCenters[frameIndex-1] = new Point(-(frameData.bounds.x*_scale.x), -(frameData.bounds.y*_scale.y));
			var bd:BitmapData = frameData.bitmapData;
            return bd;
        }

		public static function getRealBounds(clip:DisplayObject):Rectangle {
			var bounds:Rectangle = clip.getBounds(clip.parent);
			bounds.x = Math.floor(bounds.x);
			bounds.y = Math.floor(bounds.y);
			bounds.height = Math.ceil(bounds.height);
			bounds.width = Math.ceil(bounds.width);
			
			var realBounds:Rectangle = new Rectangle(0, 0, bounds.width, bounds.height);
			
			// Checking filters in case we need to expand the outer bounds
			if (clip.filters.length > 0)
			{
				// filters
				var j:int = 0;
				//var clipFilters:Array = clipChild.filters.concat();
				var clipFilters:Array = clip.filters;
				var clipFiltersLength:int = clipFilters.length;
				var tmpBData:BitmapData;
				var filterRect:Rectangle;
				
				tmpBData = new BitmapData(realBounds.width, realBounds.height, false);
				filterRect = tmpBData.generateFilterRect(tmpBData.rect, clipFilters[j]);
				tmpBData.dispose();
				
				while (++j < clipFiltersLength)
				{
					tmpBData = new BitmapData(filterRect.width, filterRect.height, true, 0);
					filterRect = tmpBData.generateFilterRect(tmpBData.rect, clipFilters[j]);
					realBounds = realBounds.union(filterRect);
					tmpBData.dispose();
				}
			}
			
			realBounds.offset(bounds.x, bounds.y);
			realBounds.width = Math.max(realBounds.width, 1);
			realBounds.height = Math.max(realBounds.height, 1);
			
			tmpBData = null;
			return realBounds;
		}
		
		public static function getBitmapDataByDisplay(clip:DisplayObject, scaleFactor : Point, clipColorTransform:ColorTransform = null, frameBounds:Rectangle=null):ImageFrameData
		{
			if(!scaleFactor)
				scaleFactor = new Point(1,1);
			var realBounds:Rectangle = getRealBounds(clip);
			
			var bdData : BitmapData = new BitmapData((realBounds.width*scaleFactor.x), (realBounds.height*scaleFactor.y), true, 0);
			var _mat : Matrix = clip.transform.matrix;
			_mat.translate(-realBounds.x, -realBounds.y);
			_mat.scale(scaleFactor.x, scaleFactor.y);
			
			bdData.draw(clip, _mat, clipColorTransform);
			
			var item:ImageFrameData = new ImageFrameData(bdData, realBounds);
			
			bdData = null;
			
			return item;
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
    }
}
import flash.display.BitmapData;

final class ImageFrameData
{
	public function ImageFrameData(data:BitmapData, bounds:flash.geom.Rectangle)
	{
		this.bitmapData = data;
		this.bounds = bounds;
	}
	public var bitmapData:BitmapData;
	public var bounds:flash.geom.Rectangle;
}

