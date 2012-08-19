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
			
			_scratchPosition.x += Math.ceil(((scrollSpeed.x) * deltaTime)); 
			_scratchPosition.y += Math.ceil(((scrollSpeed.y) * deltaTime));	
			if(_initialDraw)
				_scratchPosition = scrollPosition;
			
			setOffset(_scratchPosition.x, _scratchPosition.y);
		}
		
		override protected function buildG2DObject():void
		{
			super.buildG2DObject();
			
			if(gpuObject)
			{
				hRatio = PBE.mainStage.stageWidth / gpuObject.width;
				vRatio = PBE.mainStage.stageHeight / gpuObject.height;
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

			//Got this scrolling code from the Starling forums thanks to @QuadWord
			//#See http://forum.starling-framework.org/topic/best-way-to-do-a-scroll-background
			yy = ((yy/(gpuObject as Image).height % 1)+1) ;
			xx = ((xx/(gpuObject as Image).width % 1)+1) ;
			_tmpPoint.setTo(xx, yy);
			(gpuObject as Image).setTexCoords(0, _tmpPoint);
			_tmpPoint.setTo(xx+hRatio, yy );
			(gpuObject as Image).setTexCoords(1, _tmpPoint);
			_tmpPoint.setTo(xx, yy + vRatio);
			(gpuObject as Image).setTexCoords(2, _tmpPoint);
			_tmpPoint.setTo(xx + hRatio, yy + vRatio);
			(gpuObject as Image).setTexCoords(3, _tmpPoint);
			
			if(_initialDraw)
				_initialDraw = false;
		}
	}
}