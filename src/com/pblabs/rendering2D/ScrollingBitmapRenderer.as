package com.pblabs.rendering2D
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.core.IAnimatedObject;
	import com.pblabs.rendering2D.BitmapRenderer;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import spark.primitives.Graphic;
	
	public class ScrollingBitmapRenderer extends SpriteRenderer
	{
		
		//-------------------------------------------------------------------------
		// public variable declarations
		//-------------------------------------------------------------------------		
		public var scrollPosition:Point = new Point(0,0);
		public var scrollSpeed:Point = new Point(0,0);
		
		//-------------------------------------------------------------------------
		// private variable declarations
		//-------------------------------------------------------------------------
		
		private var scrollRect:Rectangle = new Rectangle();	// will hold the drawing area
		private var _scratchPosition : Point = new Point();
		private var _zeroPoint : Point = new Point();
		private var _m : Matrix = new Matrix();

		//-------------------------------------------------------------------------
		// public methods
		//-------------------------------------------------------------------------				
		/**
		 * constructor
		 * 
		 * @param bitmap:Bitmap is provided bitmap for repeating background
		 * @param width:int is Scrolling Bitmap width dimension
		 * @param height:int is Scrolling Bitmap height dimension
		 */
		public function ScrollingBitmapRenderer()
		{
			// call inherited constructor
			super();
		}
		
		override public function set bitmapData(value:BitmapData):void
		{
			if (value === bitmap.bitmapData)
				return;
			
			// store orginal BitmapData so that modifiers can be re-implemented 
			// when assigned modifiers attribute later on.
			originalBitmapData = value;
		
			// check if we should do modification
			if (modifiers.length>0)
			{
				// apply all bitmapData modifiers
				bitmap.bitmapData = modify(originalBitmapData.clone());
				dataModified();			
			} else {				
				bitmap.bitmapData = value;
			}
			
			if (displayObject==null)
			{
				_displayObject = new Sprite();
				_displayObject.visible = true;
				(_displayObject as Sprite).mouseEnabled = _mouseEnabled;
			}
			
			// Due to a bug, this has to be reset after setting bitmapData.
			smoothing = _smoothing;
			_transformDirty = true;
		}

		public override function isPixelPathActive(objectToScreen:Matrix):Boolean
		{
			return false;
		}
		
		public override function onFrame(deltaTime:Number):void
		{
			paintRenderer(deltaTime);
			// call onFrame of the extended BitmapRenderer
			super.onFrame(deltaTime);
		}
		
		override protected function onAdd():void
		{
			snapToNearestPixels = false;
			super.onAdd();
		}
		
		private var _painted : Boolean = false;
		protected function paintRenderer(deltaTime:Number):void
		{
			if(!bitmapData) 
				return;

			if(!size || size.x == 0 || size.y == 0) 
				return;
			
			updateProperties();
			
			// adjust scroll offset using the scrollSpeed
			_scratchPosition.x += (scrollSpeed.x * deltaTime); 
			_scratchPosition.y += (scrollSpeed.y * deltaTime);	
			// determine the right drawing rectangle area of the bitmapData object with all display info 
			// for the copyPixel command
			// determine x offset of rectangle draw area 
			var dx:Number = _scratchPosition.x - (Math.floor(_scratchPosition.x/originalBitmapData.width)*originalBitmapData.width);
			if(!_painted)
				dx += scrollPosition.x;
			scrollRect.x = dx;
			if((int(dx) % originalBitmapData.width) == 0)
				scrollRect.x = 0;
			// determine y offset of rectangle draw area 
			var dy:Number = _scratchPosition.y - (Math.floor((_scratchPosition.y)/originalBitmapData.height)*originalBitmapData.height);
			if(!_painted)
				dy += scrollPosition.y;
			scrollRect.y = dy;			
			if((int(dy) % originalBitmapData.height) == 0)
				scrollRect.y = 0;
			
			_m.identity();
			_m.translate(scrollRect.x, scrollRect.y);
			// Position to match scene view.
			(_displayObject as Sprite).graphics.clear();
			(_displayObject as Sprite).graphics.beginBitmapFill(originalBitmapData, _m, true, true); 
			(_displayObject as Sprite).graphics.drawRect(0,0, size.x, size.y);
			(_displayObject as Sprite).graphics.endFill();
			
			if(!_painted)
			{
				_painted = true;
			}
		}
		
	}
}
