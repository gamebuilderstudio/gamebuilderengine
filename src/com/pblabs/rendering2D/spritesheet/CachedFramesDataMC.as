package com.pblabs.rendering2D.spritesheet
{
	import flash.display.MovieClip;
	import flash.geom.Rectangle;

	public class CachedFramesDataMC extends CachedFramesData
	{
		public var frameCenters:Array;
		public var clip:MovieClip;

		public function CachedFramesDataMC(frames:Array, bounds:Rectangle, clip:MovieClip, frameCenters : Array)
		{
			super(frames, null, null, bounds);
			this.frameCenters = frameCenters;
			this.clip = clip;
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