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
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.utils.getNextPowerOfTwo;

	public class ScrollingBitmapRendererG2D extends SpriteRendererG2D
	{
		//-------------------------------------------------------------------------
		// public variable declarations
		//-------------------------------------------------------------------------		
		public var scrollPosition:Point = new Point(0,0);
		public var scrollSpeed:Point = new Point(0,0);

		private var scrollRect:Rectangle = new Rectangle();	// will hold the drawing area
		private var _scratchPosition : Point = new Point();
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
			
			_scratchPosition.x = ((scrollSpeed.x) * deltaTime); 
			_scratchPosition.y = ((scrollSpeed.y) * deltaTime);	
			if(_initialDraw)
				_scratchPosition = scrollPosition;
			
			setOffset(_scratchPosition.x, _scratchPosition.y);
		}
		
		override protected function buildG2DObject():void
		{
			var legalWidth:int  = getNextPowerOfTwo(bitmapData.width);
			var legalHeight:int = getNextPowerOfTwo(bitmapData.height);
			if (legalWidth > bitmapData.width || legalHeight > bitmapData.height)
			{
				//TODO: Alter original image to equal power of two.
			}

			super.buildG2DObject();
			
			if(gpuObject)
			{
				var tileH : Number = _size.x / (gpuObject as Image).texture.width;
				var tileV : Number = _size.y / (gpuObject as Image).texture.height;
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

		public function setOffset(xx:Number, yy:Number):void
		{
			if(!gpuObject)
				return;
			
			if(!(gpuObject as Image).texture.repeat)
				(gpuObject as Image).texture.repeat = true;

			for (var i:int = 0; i < 4; i++) 			
			{ 				
				var textrPoint : Point = (gpuObject as Image).getTexCoords(i); 				
				textrPoint.x -= xx * .002; 				
				textrPoint.y -= yy * .002; 				
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
	}
}