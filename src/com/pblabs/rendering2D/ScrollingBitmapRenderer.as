/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2012 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
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
		private var _scrollingBitmapData:BitmapData;	// will hold all display data
		private var _zeroPoint : Point = new Point();
		
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
		
		public override function isPixelPathActive(objectToScreen:Matrix):Boolean
		{
			return false;
		}
		
		public override function onFrame(deltaTime:Number):void
		{
			// call onFrame of the extended BitmapRenderer
			super.onFrame(deltaTime);
			paintRenderer(deltaTime);
		}
		
		override protected function onAdd():void
		{
			snapToNearestPixels = false;
			super.onAdd();
		}
		
		private var _initialScroll : Boolean = false;
		protected function paintRenderer(deltaTime:Number):void
		{
			if(!bitmapData) 
				return;

			if(!size || size.x == 0 || size.y == 0) 
				return;
			
			if(!_scrollingBitmapData)
			{
				drawOriginalScrollingBitmap();
			}
			
			// adjust scroll offset using the scrollSpeed
			_scratchPosition.x += (scrollSpeed.x * deltaTime); 
			_scratchPosition.y += (scrollSpeed.y * deltaTime);	
			// determine the right drawing rectangle area of the bitmapData object with all display info 
			// for the copyPixel command
			// determine x offset of rectangle draw area 
			var dx:Number = _scratchPosition.x - (Math.floor(_scratchPosition.x/originalBitmapData.width)*originalBitmapData.width);
			if(!_initialScroll)
				dx += scrollPosition.x;
			scrollRect.x = dx;
			if((int(dx) % originalBitmapData.width) == 0)
				scrollRect.x = 0;
			// determine y offset of rectangle draw area 
			var dy:Number = _scratchPosition.y - (Math.floor((_scratchPosition.y)/originalBitmapData.height)*originalBitmapData.height);
			if(!_initialScroll)
				dy += scrollPosition.y;
			scrollRect.y = dy;			
			if((int(dy) % originalBitmapData.height) == 0)
				scrollRect.y = 0;
			
			// Position to match scene view.
			_scrollingBitmapData.scroll(scrollRect.x, scrollRect.y);
			
			if(!_initialScroll)
			{
				_initialScroll = true;
			}
		}
		
		protected function drawOriginalScrollingBitmap():void
		{
			if(!size || size.x == 0 || size.y == 0 || !originalBitmapData) 
				return;
			
			if(_scrollingBitmapData)
				_scrollingBitmapData.dispose();
			
			// determine how many times the bitmap has to be drawn horizontal and vertical
			// to fill the scrolling bitmap.
			// We add an aditional so that we have enough display to scroll in any direction			
			var cx:int = Math.ceil(_size.x/originalBitmapData.width)+1;
			var cy:int = Math.ceil(_size.y/originalBitmapData.height)+1;
			// the scrollrect variable will be used to draw a specific area to the scrolling bitmap			
			scrollRect = new Rectangle(0,0,size.x,size.y);
			// create a bitmapData object that will contain all display info that will
			// be used when copying pixels to the scrolling bitmap
			_scrollingBitmapData = new BitmapData(cx*originalBitmapData.width, cy*originalBitmapData.height, true, 0x000000);
			// fill the bitmapData object with all display info with the provided bitmap 
			for (var ix:int = 0; ix<cx; ix++){
				for (var iy:int = 0; iy<cy; iy++)
				{
					_scrollingBitmapData.copyPixels(originalBitmapData,originalBitmapData.rect, new Point(ix*originalBitmapData.width,iy*originalBitmapData.height));
				}
			}
			bitmapData = _scrollingBitmapData;
		}		
		
		override public function set bitmapData(value:BitmapData):void
		{
			if (value === bitmap.bitmapData)
				return;
			
			// store orginal BitmapData so that modifiers can be re-implemented 
			// when assigned modifiers attribute later on.
			originalBitmapData = value;
			if(!_scrollingBitmapData){
				drawOriginalScrollingBitmap();
				return;
			}
			
			// check if we should do modification
			if (modifiers.length>0)
			{
				// apply all bitmapData modifiers
				bitmap.bitmapData = modify(_scrollingBitmapData);
				dataModified();			
			} else {				
				bitmap.bitmapData = _scrollingBitmapData;
			}
			
			if (displayObject==null)
			{
				_displayObject = new Sprite();
				(_displayObject as Sprite).addChild(bitmap);				
				_displayObject.visible = false;
				(_displayObject as Sprite).mouseEnabled = _mouseEnabled;
			}
			
			// Due to a bug, this has to be reset after setting bitmapData.
			smoothing = _smoothing;
			_transformDirty = true;
		}
		
		override public function set size(value:Point):void
		{
			if(size.x == value.x && size.y == value.y) 
				return;
			super.size = value;
			drawOriginalScrollingBitmap();
		}		
	}
}
