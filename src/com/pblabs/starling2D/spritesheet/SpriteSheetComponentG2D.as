/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2012 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.starling2D.spritesheet
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.PBUtil;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.rendering2D.spritesheet.CachedFramesData;
	import com.pblabs.rendering2D.spritesheet.SpriteSheetComponent;
	import com.pblabs.starling2D.InitializationUtilG2D;
	import com.pblabs.starling2D.ResourceTextureManagerG2D;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import starling.core.Starling;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class SpriteSheetComponentG2D extends SpriteSheetComponent implements ISpriteSheetG2D
	{
		public function SpriteSheetComponentG2D()
		{
			super();
			InitializationUtilG2D.disposed.add(releaseTextures);
		}
		
		public static function releaseTextures():void
		{
			for(var key : String in _frameCache)
			{
				var cache : CachedFramesDataG2D = _frameCache[key] as CachedFramesDataG2D;
				if(cache){
					delete _frameCache[key];
					cache.destroy();
				}
			}
			_frameCache = new Dictionary(true);
			InitializationUtilG2D.disposed.remove(releaseTextures);
		}
		
		override public function getFrame(index:int, direction:Number=0.0):BitmapData{ return null; }

		override protected function getRawFrame(index:int):BitmapData{ return super.getRawFrame(index); }

		override protected function getSourceFrames() : Array
		{
			if(!Starling.context){
				return null;
			}

			// If user provided their own bitmapdatas, return those.
			/*if(_forcedBitmaps)
				return _forcedBitmaps;*/
			
			var _frames:Array;
			
			// image isn't loaded, can't do anything yet
			if (!_image || !_image.bitmapData)
				return null;
			
			var cachedFrames : CachedFramesData = getCachedFrames();
			if (_cached && cachedFrames)
			{
				cachedFrames.released.addOnce(onCacheReleased);
				cachedFrames.referenceCount += 1;
				_divider = cachedFrames.divider ? cachedFrames.divider.copy(_divider) : _divider;
				_bounds = cachedFrames.bounds ? cachedFrames.bounds : _bounds;
				return cachedFrames.frames;
			}
			
			var atlas : TextureAtlas = ResourceTextureManagerG2D.getTextureAtlasForResource(_image);
			var atlasTexture : Texture;
			if(!atlas){
				atlasTexture = Texture.fromBitmapData(_image.bitmapData);
				atlas = new TextureAtlas(atlasTexture);
				//ResourceTextureManagerG2D.mapTextureToResource(atlasTexture, _image);
				ResourceTextureManagerG2D.mapTextureAtlasToResource(atlas, _image);
			}
			// no divider means treat the image as a single frame
			if (!_divider)
			{
				_frames = new Array(1);
				_frames[0] = ResourceTextureManagerG2D.getTextureForAtlasRegion(atlas, "i_0", new Rectangle(0,0, atlasTexture.width, atlasTexture.height));
			}
			else
			{
				_frames = new Array(_divider.frameCount);
				var tmpBounds : Rectangle;
				for (var i:int = 0; i < _divider.frameCount; i++)
				{
					var area:Rectangle = _divider.getFrameArea(i);
					var regionSubTexture : Texture = ResourceTextureManagerG2D.getTextureForAtlasRegion(atlas, "i_"+i, area);
					_frames[i] = regionSubTexture;
					
					tmpBounds = area;
					if(!_bounds){
						_bounds = tmpBounds;
					}else{
						var difX : Number = PBUtil.clamp( tmpBounds.width - _bounds.width, 0, 99999999);
						var difY : Number = PBUtil.clamp( tmpBounds.height - _bounds.height, 0, 99999999);
						_bounds.inflate(difX, difY);
					}
					
				}				
			}		
			
			if(cached){
				var frameCache : CachedFramesData = new CachedFramesDataG2D(_frames, imageFilename, _divider, _bounds, atlas);
				frameCache.released.addOnce(onCacheReleased);
				frameCache.referenceCount += 1;
				setCachedFrames(frameCache);
			}
			return _frames;
		}

		override protected function buildFrames():void
		{
			frames = getSourceFrames();
			
			// not loaded, can't do anything yet
			if (frames == null)
				return;
			
			if (frames.length == 0)
				Logger.error(this, "buildFrames", "Error - No frames loaded");
			
			// BitmapData modification implementation
			/*if (frames!=null && modifiers.length>0)
			{
				// loop all frames
				for (var f:int = 0; f<frames.length; f++)
				{
					// get frame
					var frame:BitmapData = (frames[f] as BitmapData).clone();						
					
					// apply BitmapData modifiers
					for (var m:int = 0; m<modifiers.length; m++)
						frame = (modifiers[m] as Modifier).modify(frame,f, frames.length);	
					
					// assign modified frame
					frames[f] = frame;
				}
				
			}*/
			
			if (frameCountCap>0)
			{
				// this frames array has to be capped because the frameCount was set manually to override	
				frames.splice(frameCountCap,frames.length-frameCountCap);
			}
			
			if (_defaultCenter)
				_center = new Point(frames[0].width * 0.5, frames[0].height * 0.5);
		}

		override public function set imageData(data : BitmapData):void
		{
			Logger.error(this, "set imageData", "You can't set the BitmapData of a GPU SpriteSheetComponent. You must use an ImageResource.");
		}
	}
}