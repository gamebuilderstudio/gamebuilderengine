package com.pblabs.rendering2D.spritesheet
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class CachedFramesDataMC extends CachedFramesData
	{
		public var frameCenters:Array;
		public var clip:MovieClip;
		public var scale : Point;

		public function CachedFramesDataMC(frames:Array, bounds:Rectangle, clip:MovieClip, frameCenters : Array, scale : Point)
		{
			super(frames, null, null, bounds);
			this.frameCenters = frameCenters;
			this.clip = clip;
			this.scale = scale;
		}
		override public function destroy():void
		{
			super.destroy();
			frameCenters = null;
			clip = null;
			referenceCount = -1;
		}
	}
}