/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.rendering2D.modifier
{
	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;

	public class ColorizeModifier extends Modifier
	{
		// --------------------------------------------------------------
		// public methods
		// --------------------------------------------------------------
		
		public function ColorizeModifier(red:Array, green:Array, blue:Array, alpha:Array)
		{
			this.red = red;
			this.green = green;
			this.blue = blue;
			this.alpha = alpha;
			// call inherited contructor
			super();
		}
				
		public override function modify(data:BitmapData, index:int=0):BitmapData
		{			
			// colorize this specific frame bitmap
			var matrix:Array = new Array();
			matrix=matrix.concat(red);// red
			matrix=matrix.concat(green);// green
			matrix=matrix.concat(blue);// blue
			matrix=matrix.concat(alpha);// alpha
			
			// set color filter
			data.lock();
			data.applyFilter(data,data.rect,new Point(0,0), new ColorMatrixFilter(matrix));
			data.unlock();

			// draw this bitmap on a BitmapData object so all effects
			// become rendered as pixels
			return data;
		}
		
		// --------------------------------------------------------------
		// private and protected properties
		// --------------------------------------------------------------
		
		private var red:Array = null;
		private var green:Array = null;
		private var blue:Array = null;
		private var alpha:Array = null;		
		
	}
}