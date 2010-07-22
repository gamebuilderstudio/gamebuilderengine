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
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	
	public class BlurModifier extends Modifier
	{
		public var blurX:Number = 6;
		public var blurY:Number = 6;
		public var quality:int = 1;
		
		public function BlurModifier(blurX:Number=6, blurY:Number=6,  quality:int=1)
		{
			this.blurX = blurX;
			this.blurY = blurY;
			this.quality = quality;
			super();
		}
		
		public override function modify(data:BitmapData, index:int=0, count:int=1):BitmapData
		{			
			data.lock();
			data.applyFilter(data,data.rect, new Point(0,0),  new BlurFilter(blurX,blurY,quality));
			data.unlock();						
			return data;			
		}
	}
}