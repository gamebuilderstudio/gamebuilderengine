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
    import com.pblabs.engine.resource.SWFResource;

    import flash.display.*;
    import flash.geom.*;
    import flash.utils.Dictionary;

    /**
     * A class that is similar to the SpriteSheetComponent except the frames
     * are loaded by rasterizing frames from a MovieClip rather than splitting
     * a single image.
     */
    public class SWFSpriteSheetComponent extends SpriteContainerComponent
    {
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
            _frames = null;
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
            _frames = null;
            _clip = null;
            deleteFrames();
        }

        /**
         * The bounds of the source MovieClip.
         * This can be used for clips that are expected to be rendered based on their bounds.
         */
        public function get bounds():Rectangle
        {
            return new Rectangle(_bounds.x, _bounds.y, _bounds.width * _scale.x, _bounds.height * _scale.y);
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
            _scale = value.clone();
        }
        
        override public function get isLoaded() : Boolean
        {
            if (!_resource || !_resource.isLoaded) 
                return false;

            if (!_frames) 
                rasterize();

            return _frames != null;
        }

        /**
         * Rasterizes the associated MovieClip and returns a list of frames.
         */
        override protected function getSourceFrames() : Array
        {
            if (!_resource || !_resource.isLoaded)
                return null;

            if (!_frames)
                rasterize();

            return _frames;
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

        override protected function getRawFrame(index:int) : BitmapData
        {
            var frame:BitmapData = super.getRawFrame(index);
            if (frame)
                return frame;

            if (!_frames || !_clip)
                return null;

            frame = rasterizeFrame(_clip, index + 1);
            _frames[index] = frame;
            
            return frame;
        }

        /**
         * Rasterizes the clip into an Array of BitmapData objects.
         * This array can then be used just like a sprite sheet.
         */
        protected function rasterize():void
        {
            if (!_resource.isLoaded) return;

            var frames:CachedFramesData = getCachedFrames();
            if (frames)
            {
                _frames = frames.frames;
                _bounds = frames.bounds;
                _clip = frames.clip;
                return;
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

            _frames = onRasterize(_clip);
            _bounds = _clip.getBounds(_clip);
            center = new Point(-_bounds.x, -_bounds.y);
            setCachedFrames(new CachedFramesData(_frames, _bounds, _clip));
        }

        /**
         * Performs the actual rasterizing. Override this to perform custom rasterizing of a clip.
         */
        protected function onRasterize(mc:MovieClip):Array
        {
            var maxFrames:int = swf.findMaxFrames(mc, mc.totalFrames);
            var rasterized:Array = new Array(maxFrames);

            if (maxFrames > 0)
                rasterized[0] = rasterizeFrame(mc, 1);

            return rasterized;
        }

        protected function rasterizeFrame(mc:MovieClip, frameIndex:int):BitmapData
        {
            if (mc.totalFrames >= frameIndex)
                mc.gotoAndStop(frameIndex);

            swf.advanceChildClips(mc, frameIndex);
            var bd:BitmapData = getBitmapDataByDisplay(mc);

            return bd;
        }

        /**
         * Draws the DisplayObject to a BitmapData using the bounds of the object.
         */
        protected function getBitmapDataByDisplay(display:DisplayObject):BitmapData 
        {
            var bounds:Rectangle = display.getBounds(display);

            var bd:BitmapData = new BitmapData(
                Math.max(1, Math.min(2880, bounds.width * scale.x)),
                Math.max(1, Math.min(2880, bounds.height * scale.y)),
                true,
                0x00000000);

            bd.draw(display, new Matrix(_scale.x, 0, 0, _scale.y, -bounds.x * _scale.x, -bounds.y * _scale.y), null, null, null, _smoothing);

            return bd;
        }

        protected static var _frameCache:Dictionary = new Dictionary(true);

        private var _smoothing:Boolean = true;
        private var _scale:Point = new Point(1, 1);
        private var _frames:Array;
        private var _resource:SWFResource;
        private var _clipName:String;
        private var _clip:MovieClip;
        private var _bounds:Rectangle;
    }
}

final class CachedFramesData
{
    public function CachedFramesData(frames:Array, bounds:flash.geom.Rectangle, clip:flash.display.MovieClip)
    {
        this.frames = frames;
        this.bounds = bounds;
        this.clip = clip;
    }
    public var frames:Array;
    public var bounds:flash.geom.Rectangle;
    public var clip:flash.display.MovieClip;
}

