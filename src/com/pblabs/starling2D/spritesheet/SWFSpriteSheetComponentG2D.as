package com.pblabs.starling2D.spritesheet
{
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.rendering2D.spritesheet.CachedFramesDataMC;
	import com.pblabs.rendering2D.spritesheet.SWFSpriteSheetComponent;
	import com.pblabs.starling2D.InitializationUtilG2D;
	import com.pblabs.starling2D.ResourceTextureManagerG2D;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import starling.core.Starling;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class SWFSpriteSheetComponentG2D extends SWFSpriteSheetComponent implements ISpriteSheetG2D
	{
		public function SWFSpriteSheetComponentG2D()
		{
			super();
			InitializationUtilG2D.disposed.add(releaseTextures);
		}
		
		public static function releaseTextures():void
		{
			for(var key : String in _frameCache)
			{
				var cacheData : CachedFramesDataMCG2D = _frameCache[key] as CachedFramesDataMCG2D;
				if(cacheData){
					cacheData.destroy();
					delete _frameCache[key];
				}
			}
			_frameCache = new Dictionary(true);
			InitializationUtilG2D.disposed.remove(releaseTextures);
		}

		override public function getFrame(index:int, direction:Number=0.0):BitmapData{ return null; }
		override public function getTexture(index:int, direction:Number=0.0):Texture
		{
			var curTexture : Texture = super.getTexture(index, direction);
			_center = _frameCenters[index];
			return curTexture;
		}
		
		/**
		 * Rasterizes the movie clip into an Array of Texture objects.
		 * This array can then be used just like a sprite sheet.
		 */
		override protected function rasterize():void
		{
			if (!_resource || !_resource.isLoaded || _resource.didFail || !Starling.context) return;
			
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
			var textureList : Array;
			if(frames){
				var len : int = frames.length;
				textureList = new Array(len);
				//Convert all Bitmaps into textures and upload to GPU
				for(var i : int = 0; i < len; i++)
				{
					textureList[i] = ResourceTextureManagerG2D.getTextureForBitmapData(frames[i] as BitmapData, getFramesCacheKey()+"_"+i);
				}
				frames = textureList;
			}
			_center = new Point(-_bounds.x, -_bounds.y);
			
			if(cached && frames){
				var frameCache : CachedFramesDataMC = new CachedFramesDataMCG2D(textureList, _bounds, _clip, _frameCenters, _scale);
				frameCache.released.addOnce(onCacheReleased);
				frameCache.referenceCount += 1;
				setCachedFrames(frameCache);
			}
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
		override protected function getRawFrame(index:int):BitmapData{ return null; }
	}
}