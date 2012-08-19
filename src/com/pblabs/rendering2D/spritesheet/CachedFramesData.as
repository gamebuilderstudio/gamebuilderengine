package com.pblabs.rendering2D.spritesheet
{
	import flash.geom.Rectangle;

	public class CachedFramesData
	{
		public function CachedFramesData(frames:Array, fileName : String, divider : ISpriteSheetDivider, bounds : Rectangle )
		{
			this.frames = frames;
			this.fileName = fileName;
			this.divider = divider;
			this.bounds = bounds;
		}
		public var frames:Array;
		public var fileName:String;
		public var divider:ISpriteSheetDivider;
		public var referenceCount : int = 0;
		public var bounds:Rectangle;
		
		public function destroy():void
		{
			if(frames){
				while(frames.length > 0)
				{
					frames[0].dispose();
					frames.splice(0,1);
				}
			}
			frames = null;
			if(divider){
				divider.destroy();
				divider = null;
			}
			bounds = null;
		}
	}
}