package com.pblabs.rendering2D
{
	import flash.display.BitmapData;

	public interface IBitmapRenderer
	{
		function get bitmapData():BitmapData;
		function set bitmapData(data : BitmapData):void;
	}
}