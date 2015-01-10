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
	import com.pblabs.engine.PBUtil;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.resource.ImageResource;
	import com.pblabs.rendering2D.spritesheet.MultiImageSpriteSheetComponent;
	import com.pblabs.starling2D.ResourceTextureManagerG2D;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.core.Starling;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	
	public class MultiImageSpriteSheetComponentG2D extends MultiImageSpriteSheetComponent implements ISpriteSheetG2D
	{
		public function MultiImageSpriteSheetComponentG2D()
		{
			super();
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
			
			// image isn't loaded, can't do anything yet
			if (!loaded)
				return null;
			
			// no divider means treat the image as a single frame
			var _frames:Array = new Array(_images.length);
			var tmpBounds : Rectangle;
			for (var i:int = 0; i < _images.length; i++)
			{
				var resource:ImageResource = _images[i];
				var texture : Texture = ResourceTextureManagerG2D.getTextureForResource(resource);
				_frames[i] = texture;
				tmpBounds = new Rectangle(0,0, texture.width, texture.height);
				if(!_bounds){
					_bounds = tmpBounds;
				}else{
					var difX : Number = PBUtil.clamp( tmpBounds.width - _bounds.width, 0, 99999999);
					var difY : Number = PBUtil.clamp( tmpBounds.height - _bounds.height, 0, 99999999);
					_bounds.inflate(difX, difY);
				}
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
		
		override protected function deleteFrames():void
		{
			for (var i:int = 0; i < frames.length; i++)
			{
				if(frames[i] is SubTexture)
					(frames[i] as SubTexture).dispose();
			}
			super.deleteFrames();
		}

		override public function set imageData(data : BitmapData):void
		{
			Logger.error(this, "set imageData", "You can't set the BitmapData of a GPU SpriteSheetComponent. You must use an ImageResource.");
		}
	}
}