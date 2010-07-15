package com.pblabs.rendering2D.modifier
{
	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;

	public class GrayscaleModifier extends Modifier
	{
		public function GrayscaleModifier()
		{
			super();
		}
		
		public override function modify(data:BitmapData, index:int = 0):BitmapData
		{
			// colorize this specific frame bitmap
			var matrix:Array = new Array();
			matrix=matrix.concat([0.3086, 0.6094, 0.0820,0,0]);// red
			matrix=matrix.concat([0.3086, 0.6094, 0.0820,0,0]);// green
			matrix=matrix.concat([0.3086, 0.6094, 0.0820,0,0]);// blue
			matrix=matrix.concat([0,0,0,1,0]);// alpha
			
			
			// set color filter
			data.lock();
			data.applyFilter(data,data.rect, new Point(0,0), new ColorMatrixFilter(matrix));
			data.unlock();
			
			// draw this bitmap on a BitmapData object so all effects
			// become rendered as pixels
			return data;
		}
		
	}
}