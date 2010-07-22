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

	public class BorderModifier extends Modifier
	{
		public var color:uint = 0xff000000;
		
		public function BorderModifier(color:uint=0xff000000)
		{
			this.color = color;
			super();
		}
		
		public override function modify(data:BitmapData, index:int=0, count:int=1):BitmapData
		{	
			data.lock();
						
			for (var y:int = 0; y<data.height; y++)
			{
				if (y==0 || y==data.height-1)
				{
					for (var x:int=0; x<data.width; x++)					
						data.setPixel32(x,y,color);
				}
				else
				{
					data.setPixel32(0,y,color);
					data.setPixel32(data.width-1,y,color);
				}
			}
			
			data.unlock();						
			return data;			
		}
		

	}
}