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
		[EditorData(inspectable="true")]
		public var scrollSpeed:Point = new Point(0,0);
		[EditorData(inspectable="true")]
		public var autoCorrectImageSize : Boolean = true;

		protected var scrollRect:Rectangle = new Rectangle();	// will hold the drawing area
		protected var _scratchPoint : Point = new Point();
		protected var _tmpPoint : Point = new Point();
		protected var _initialDraw : Boolean = true;
		
		protected var hRatio : Number = -1;
		protected var vRatio : Number = -1;
		protected var customBitmapCreated : Boolean = false;
		protected var textureWidth : Number = 0;
		protected var textureHeight : Number = 0;

		public function ScrollingBitmapRendererG2D()
		{
			super();
		}
		
		public override function onFrame(deltaTime:Number):void
		{
			// call onFrame of the extended BitmapRenderer
			super.onFrame(deltaTime);
			
			_scratchPoint.x -= (scrollSpeed.x * deltaTime); 
			_scratchPoint.y -= (scrollSpeed.y * deltaTime);	
			
			offsetTexture(_scratchPoint.x, _scratchPoint.y);
		}
		
		public function offsetTexture(xx:Number, yy:Number):void
		{
			if(!gpuObject || (!_initialDraw && PBE.IN_EDITOR))
				return;
			
			if(!(gpuObject as Image).texture.repeat)
				(gpuObject as Image).texture.repeat = true;
			
			var imageText : Image = (gpuObject as Image);
			xx = ((xx/textureWidth % 1)+1);
			yy = ((yy/textureHeight % 1)+1);
			imageText.setTexCoords(0, new Point(xx, yy));//top left
			imageText.setTexCoords(1, new Point(xx+hRatio, yy));//top right
			imageText.setTexCoords(2, new Point(xx, yy + vRatio));//bottom left
			imageText.setTexCoords(3, new Point(xx+hRatio, yy + vRatio));//bottom right

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
			if(!this.bitmap || !this.bitmap.bitmapData)
				return;

			var legalWidth:int  = getNextPowerOfTwo(bitmapData.width);
			var legalHeight:int = getNextPowerOfTwo(bitmapData.height);
			if (autoCorrectImageSize && (legalWidth > bitmapData.width || legalHeight > bitmapData.height))
			{
				customBitmapCreated = true;
				bitmapData = increaseBitmapByPowerOfTwo(bitmapData, legalWidth, legalHeight);
				return;
			}else{
				customBitmapCreated = false;
			}
			
			super.buildG2DObject();
			
			if(gpuObject)
			{
				textureWidth = (gpuObject as Image).texture.width;
				textureHeight = (gpuObject as Image).texture.height;
				if(hRatio == -1)
					hRatio = Math.round(_size.x / textureWidth);
				if(vRatio == -1)
					vRatio = Math.round(_size.y / textureHeight);
				//var intialPosX : Number = scrollPosition.x / _size.x;
				//var intialPosY : Number = scrollPosition.y / _size.y;
				(gpuObject as Image).texture.repeat = true;
				//(gpuObject as Image).setTexCoords(0, new Point(0, 0 ));
				(gpuObject as Image).setTexCoords(1, new Point(hRatio, 0 ));
				(gpuObject as Image).setTexCoords(2, new Point(0, vRatio));
				(gpuObject as Image).setTexCoords(3, new Point(hRatio, vRatio));
			}
		}
		
		override protected function onAdd():void
		{
			super.onAdd();
			buildG2DObject();
		}
		
		override protected function onRemove():void
		{
			super.onRemove();
			if(customBitmapCreated){
				originalBitmapData.dispose();
				customBitmapCreated = false;
			}
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