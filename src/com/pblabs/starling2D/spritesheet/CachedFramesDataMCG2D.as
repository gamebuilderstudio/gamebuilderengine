package com.pblabs.starling2D.spritesheet
{
	import com.pblabs.rendering2D.spritesheet.CachedFramesDataMC;
	
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.textures.Texture;
	
	public class CachedFramesDataMCG2D extends CachedFramesDataMC
	{
		
		public function CachedFramesDataMCG2D(frames:Array, bounds:Rectangle, clip:MovieClip, frameCenters:Array, scale : Point)
		{
			super(frames, bounds, clip, frameCenters, scale);
		}
	}
}