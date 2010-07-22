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
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	public class GlowModifier extends Modifier
	{
		// --------------------------------------------------------------
		// public getter/setter functions
		// --------------------------------------------------------------
		public var color:uint = 0xff0000;
		public var alpha:Number = 1;
		public var blurX:Number = 6;
		public var blurY:Number = 6;
		public var strength:Number = 2;
		public var quality:int = 1;
		
		
		// --------------------------------------------------------------
		// public methods
		// --------------------------------------------------------------
		
		public function GlowModifier(color:uint, alpha:Number=1, blurX:Number=6, blurY:Number=6,  strength:Number=2, quality:int=1)
		{
			this.color = color;
			this.alpha = alpha;
			this.blurX = blurX;
			this.blurY = blurY;
			this.strength = strength;
			this.quality = quality;
			// call inherited contructor
			super();
		}
		
		public override function modify(data:BitmapData, index:int = 0 , count:int=1):BitmapData
		{
			data.lock();
			data.applyFilter(data,data.rect, new Point(0,0),new GlowFilter(color,alpha,blurX,blurY,strength,quality));
			data.unlock();
			return data;
		}
		
		// --------------------------------------------------------------
		// private and protected properties
		// --------------------------------------------------------------
				
	}
}