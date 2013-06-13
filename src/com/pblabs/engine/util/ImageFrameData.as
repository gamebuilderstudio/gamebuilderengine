package com.pblabs.engine.util
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;

	public final class ImageFrameData
	{
		public function ImageFrameData(data:BitmapData, bounds:Rectangle)
		{
			this.bitmapData = data;
			this.bounds = bounds;
		}
		public var bitmapData:BitmapData;
		public var bounds:flash.geom.Rectangle;
	}
}