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
	
	public class ScrollingBitmapRenderer extends SpriteRenderer
	{
		
		//-------------------------------------------------------------------------
		// public variable declarations
		//-------------------------------------------------------------------------		
		public var scrollPosition:Point = new Point(0,0);
		public var scrollSpeed:Point = new Point(0,0);
		
		//-------------------------------------------------------------------------
		// protected variable declarations
		//-------------------------------------------------------------------------		
		protected var canvasBitmapData : BitmapData;

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
		
		override public function set size(value:Point):void
		{
			if(size.x == value.x && size.y == value.y) return;
			super.size = value;
			drawOriginalScrollingBitmap();
		}
		
		override public function set bitmapData(value:BitmapData):void
		{
			if (value === bitmap.bitmapData)
				return;
			
			// store orginal BitmapData so that modifiers can be re-implemented 
			// when assigned modifiers attribute later on.
			if(value != canvasBitmapData){ 
				originalBitmapData = value;
				drawOriginalScrollingBitmap();
			
				// check if we should do modification
				if (modifiers.length>0)
				{
					// apply all bitmapData modifiers
					bitmap.bitmapData = modify(originalBitmapData.clone());
					dataModified();			
				} else {				
					bitmap.bitmapData = value.clone();
				}
				
				if (displayObject==null)
				{
					_displayObject = new Sprite();
					(_displayObject as Sprite).addChild(bitmap);				
					_displayObject.visible = false;
					(_displayObject as Sprite).mouseEnabled = _mouseEnabled;
				}
			}else{
				bitmap.bitmapData = value;
			}
			
			// Due to a bug, this has to be reset after setting bitmapData.
			smoothing = _smoothing;
			_transformDirty = true;
		}

		public override function onFrame(deltaTime:Number):void
		{
			// call onFrame of the extended BitmapRenderer
			super.onFrame(deltaTime);
			paintRenderer(deltaTime);
		}
		
		protected function paintRenderer(deltaTime:Number):void
		{
			if(!scene || !scene.sceneView || !bitmapData) return;

			if(!_scrollingBitmapPainted)
			{
				drawOriginalScrollingBitmap();
				_scrollingBitmapPainted = true;
			}
			if(canvasBitmapData && scrollSpeed.x == 0 && scrollSpeed.y == 0)
				return;
			
			// adjust scroll offset using the scrollSpeed
			_scratchPosition.x += scrollPosition.x + (scrollSpeed.x * deltaTime); 
			_scratchPosition.y += scrollPosition.y + (scrollSpeed.y * deltaTime);			
			// determine the right drawing rectangle area of the bitmapData object with all display info 
			// for the copyPixel command
			// determine x offset of rectangle draw area 
			var dx:int = _scratchPosition.x - (Math.floor(_scratchPosition.x/originalBitmapData.width)*originalBitmapData.width);
			scrollRect.x = dx % originalBitmapData.width;
			if((dx % originalBitmapData.width) == 0)
				scrollRect.x = 0;
			// determine y offset of rectangle draw area 
			var dy:int = (_scratchPosition.y) - (Math.floor((_scratchPosition.y)/originalBitmapData.height)*originalBitmapData.height);
			scrollRect.y = dy;			
			if((dy % originalBitmapData.height) == 0)
				scrollRect.y = 0;
			
			if(!size || size.x == 0 || size.y == 0) return;
			
			if(!canvasBitmapData || canvasBitmapData.width != size.x || canvasBitmapData.height != size.y)
			{
				canvasBitmapData = new BitmapData(size.x, size.y, true, 0xFFFFFF);
			}
			// clear the bitmapData using blank rect
			canvasBitmapData.fillRect(canvasBitmapData.rect, 0);
			// lock the bitmapData object so no changes will be displayed until it is unlocked 
			canvasBitmapData.lock();

			// draw the right area of the bitmapData object with all display info onto the scrolling bitmap 
			canvasBitmapData.copyPixels(scrollBitmapData, scrollRect, _zeroPoint, null, null, true);
			// unlock the bitmapData object so it can be displayed 
			canvasBitmapData.unlock();			
			
			this.bitmapData = canvasBitmapData;
		}
		
		protected function drawOriginalScrollingBitmap():void
		{
			if(!size || size.x == 0 || size.y == 0 || !bitmapData) return;

			// determine how many times the bitmap has to be drawn horizontal and vertical
			// to fill the scrolling bitmap.
			// We add an aditional so that we have enough display to scroll in any direction			
			var cx:int = Math.ceil(_size.x/originalBitmapData.width)+1;
			var cy:int = Math.ceil(_size.y/originalBitmapData.height)+1;
			// the scrollrect variable will be used to draw a specific area to the scrolling bitmap			
			scrollRect = new Rectangle(0,0,size.x,size.y);
			// create a bitmapData object that will contain all display info that will
			// be used when copying pixels to the scrolling bitmap
			scrollBitmapData = new BitmapData(cx*originalBitmapData.width, cy*originalBitmapData.height, true, 0x000000);
			// fill the bitmapData object with all display info with the provided bitmap 
			for (var ix:int = 0; ix<cx; ix++){
				for (var iy:int = 0; iy<cy; iy++)
				{
					scrollBitmapData.copyPixels(originalBitmapData,originalBitmapData.rect, new Point(ix*originalBitmapData.width,iy*originalBitmapData.height));
				}
			}
		}
		
		//-------------------------------------------------------------------------
		// private variable declarations
		//-------------------------------------------------------------------------		
		private var scrollBitmapData:BitmapData;	// will hold all display data
		private var scrollRect:Rectangle = null;	// will hold the drawing area
		private var _scratchPosition : Point = new Point();
		private var _zeroPoint : Point = new Point();
		private var _scrollingBitmapPainted : Boolean = false;
		
	}
}
