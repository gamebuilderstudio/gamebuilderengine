package com.pblabs.rendering2D.modifier
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.filters.BlurFilter;
	import flash.geom.Point;

	public class BloomModifier extends Modifier
	{
		public function BloomModifier(strength:Number=4, quality:int=2, depth:int=3)
		{
			this.strength = strength;
			this.quality = quality;
			this.depth = depth;
			super();
		}
		
		public override function modify(data:BitmapData, index:int = 0):BitmapData
		{
			var buffer:BitmapData = new BitmapData(data.width,data.height,data.transparent);
			var bloom:BlurFilter = new BlurFilter(strength,strength,quality); 
			
			data.lock();
			
			buffer.lock();
			buffer.applyFilter(data,data.rect, new Point(0,0),  bloom);
			buffer.unlock();
			data.draw(buffer,null,null,BlendMode.ADD);

			for (var p:int=0; p<depth-1; p++)
			{				
				buffer.lock();
				buffer.applyFilter(buffer,buffer.rect, new Point(0,0),  bloom);
				buffer.unlock();
				data.draw(buffer,null,null,BlendMode.ADD);
			}

			data.unlock();
			
			return data;			
		}
		
		private var strength:Number = 4;
		private var quality:int = 2;
		private var depth:int = 3;
		
	}
}