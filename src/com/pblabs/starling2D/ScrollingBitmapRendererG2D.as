/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2012 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.starling2D
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.debug.Logger;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.utils.getNextPowerOfTwo;

	public class ScrollingBitmapRendererG2D extends SpriteRendererG2D
	{
		//-------------------------------------------------------------------------
		// public variable declarations
		//-------------------------------------------------------------------------		
		public var scrollSpeed:Point = new Point(0,0);

		private var scrollRect:Rectangle = new Rectangle();	// will hold the drawing area
		private var _scratchPoint : Point = new Point();
		private var _tmpPoint : Point = new Point();
		private var _initialDraw : Boolean = true;
		protected var hRatio : Number;
		protected var vRatio : Number;

		public function ScrollingBitmapRendererG2D()
		{
			super();
		}
		
		public override function onFrame(deltaTime:Number):void
		{
			// call onFrame of the extended BitmapRenderer
			super.onFrame(deltaTime);
			
			_scratchPoint.x = ((scrollSpeed.x) * deltaTime); 
			_scratchPoint.y = ((scrollSpeed.y) * deltaTime);	
			
			setOffset(_scratchPoint.x, _scratchPoint.y);
		}
		
		public function setOffset(xx:Number, yy:Number):void
		{
			if(!gpuObject || (!_initialDraw && PBE.processManager.timeScale == 0))
				return;
			
			if(!(gpuObject as Image).texture.repeat)
				(gpuObject as Image).texture.repeat = true;

			for (var i:int = 0; i < 4; i++) 			
			{ 				
				//Logger.print(this, "Vertex ["+i+"] - X="+ xx + ", Y="+yy);
				var textrPoint : Point = (gpuObject as Image).getTexCoords(i, _scratchPoint); 				
				textrPoint.x -= xx * .0014; 				
				textrPoint.y -= yy * .0014; 
				//Logger.print(this, textrPoint.toString());
				(gpuObject as Image).setTexCoords(i, textrPoint); 	
			}

			if(_initialDraw)
				_initialDraw = false;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateTransform(updateProps:Boolean = false):void
		{
			super.updateTransform(updateProps);

			if(!gpuObject){
				return;
			}
			gpuObject.width = _size.x;
			gpuObject.height = _size.y;
		}
		
		
		override protected function buildG2DObject():void
		{
			var legalWidth:int  = getNextPowerOfTwo(bitmapData.width);
			var legalHeight:int = getNextPowerOfTwo(bitmapData.height);
			if (legalWidth > bitmapData.width || legalHeight > bitmapData.height)
			{
				bitmapData = increaseBitmapByPowerOfTwo(bitmapData, legalWidth, legalHeight);
				return;
			}
			
			super.buildG2DObject();
			
			if(gpuObject)
			{
				var tileH : Number = _size.x / (gpuObject as Image).texture.width;
				var tileV : Number = _size.y / (gpuObject as Image).texture.height;
				//var intialPosX : Number = scrollPosition.x / _size.x;
				//var intialPosY : Number = scrollPosition.y / _size.y;
				(gpuObject as Image).texture.repeat = true;
				//(gpuObject as Image).setTexCoords(0, new Point(0, 0 ));
				(gpuObject as Image).setTexCoords(1, new Point(tileH, 0 ));
				(gpuObject as Image).setTexCoords(2, new Point(0, tileV));
				(gpuObject as Image).setTexCoords(3, new Point(tileH, tileV));
			}
		}
		
		override protected function onAdd():void
		{
			super.onAdd();
			buildG2DObject();
		}
		
		protected function increaseBitmapByPowerOfTwo(data : BitmapData, targetW : Number, targetH : Number):BitmapData
		{
			if(!data) 
				return null;
			
			// determine how many times the bitmap has to be drawn horizontal and vertical
			// to fill the scrolling bitmap.
			// We add an aditional so that we have enough display to scroll in any direction			
			var cx:int = Math.ceil(targetW/data.width);
			var cy:int = Math.ceil(targetH/data.height);
			
			var newBitmapData : BitmapData = new BitmapData(targetW, targetH, true, 0x00000000);
			// fill the bitmapData object with all display info with the provided bitmap 
			for (var ix:int = 0; ix<cx; ix++){
				for (var iy:int = 0; iy<cy; iy++)
				{
					newBitmapData.copyPixels(data,data.rect, new Point(ix*data.width,iy*data.height));
				}
			}
			return newBitmapData;
		}		
		
	}
}