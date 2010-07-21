package com.pblabs.rendering2D.modifier
{
	import flash.display.BitmapData;

	public class BorderModifier extends Modifier
	{
		public function BorderModifier(color:uint=0xff000000)
		{
			this.color = color;
			super();
		}
		
		public override function modify(data:BitmapData, index:int=0):BitmapData
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
		
		private var color:uint = 0xff000000;

	}
}