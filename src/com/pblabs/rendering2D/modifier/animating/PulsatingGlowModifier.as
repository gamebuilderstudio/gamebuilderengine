package com.pblabs.rendering2D.modifier.animating
{
	import com.pblabs.rendering2D.modifier.GlowModifier;
	import com.pblabs.rendering2D.modifier.Modifier;
	
	import flash.display.BitmapData;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	public class PulsatingGlowModifier extends Modifier
	{
		public function PulsatingGlowModifier(fromGlow:GlowModifier, toGlow:GlowModifier)
		{
			this.fromGlow = fromGlow;
			this.toGlow = toGlow;
			// call inherited contructor
			super();
		}
		
		public override function modify(data:BitmapData, index:int = 0, count:int=1 ):BitmapData
		{
			// calculate tweened glow values
			var fIndex:int = index;
			var fCount:int = Math.floor(count/2);
			
			
			if (index>= fCount)
			{
				fCount = count-fCount;
				fIndex = fCount-(index-(Math.floor(count/2)));
			}

			color = fromGlow.color;
			if (color!=toGlow.color)
			{  
				// color interpolation
				var fromR:uint = (color >> 16) & 0xFF;			
				var fromG:uint = (color >> 8) & 0xFF;			
				var fromB:uint = color & 0xFF;			
				var toR:uint = (toGlow.color >> 16) & 0xFF;			
				var toG:uint = (toGlow.color >> 8) & 0xFF;			
				var toB:uint = toGlow.color & 0xFF;
				var resultR:uint = ease(fIndex,fromR,toR-fromR,fCount);
				var resultG:uint = ease(fIndex,fromG,toG-fromG,fCount);			
				var resultB:uint = ease(fIndex,fromB,toB-fromB,fCount);			
				color = resultR << 16 | resultG << 8 | resultB;
			}
			if (toGlow.alpha!=fromGlow.alpha)
				alpha = ease(fIndex,fromGlow.alpha,toGlow.alpha-fromGlow.alpha,fCount);
			else
				alpha = fromGlow.alpha;			
			if (toGlow.blurX!=fromGlow.blurX)
				blurX = ease(fIndex,fromGlow.blurX,toGlow.blurX-fromGlow.blurX,fCount);
			else
				blurX = fromGlow.blurX;
			if (toGlow.blurY!=fromGlow.blurY)
				blurY = ease(fIndex,fromGlow.blurY,toGlow.blurY-fromGlow.blurY,fCount);
			else
				blurY = fromGlow.blurY;
			if (toGlow.strength!=fromGlow.strength)
				strength = ease(fIndex,fromGlow.strength,toGlow.strength-fromGlow.strength,fCount);
			else
				strength = fromGlow.strength;
			if (toGlow.quality!=fromGlow.quality)
				quality = ease(fIndex,fromGlow.quality,toGlow.quality-fromGlow.quality,fCount);
			else
				quality = fromGlow.quality;
						
			data.lock();
			data.applyFilter(data,data.rect, new Point(0,0),new GlowFilter(color,alpha,blurX,blurY,strength,quality));
			data.unlock();
			
			return data;
		}

		// color interpolation
		
		
		// Sin easing
		private function ease(t:Number, b:Number, c:Number, d:Number):Number
		{
			return -c * Math.cos(t / d * (Math.PI / 2)) + c + b;
		}
		
		// --------------------------------------------------------------
		// private and protected properties
		// --------------------------------------------------------------
		private var fromGlow:GlowModifier;
		private var toGlow:GlowModifier;

		private var color:uint = 0xff0000;
		private var alpha:Number = 1;
		private var blurX:Number = 6;
		private var blurY:Number = 6;
		private var strength:Number = 2;
		private var quality:int = 1;

				
	}
}