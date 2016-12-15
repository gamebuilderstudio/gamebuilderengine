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
	import com.pblabs.engine.core.ObjectType;
	import com.pblabs.engine.resource.ResourceManager;
	import com.pblabs.rendering2D.SimpleShapeRenderer;
	
	import flash.geom.Point;
	
	import starling.core.Starling;
	import starling.display.Canvas;
	
	public class BitmapShapeRendererG2D extends SimpleShapeRenderer
	{
		protected var _smoothing:Boolean = false;

		public function BitmapShapeRendererG2D()
		{
			_smoothing = false;
			_lineSize = 0;
			_lineAlpha = 0;
		}
		
		override public function pointOccupied(worldPosition:Point, mask:ObjectType):Boolean
		{
			if (!gpuObject || !scene)
				return false;
			
			var localPos:Point = transformWorldToObject(worldPosition);
			return gpuObject.hitTest(localPos) ? true : false;
		}

		override protected function buildG2DObject(skipCreation : Boolean = false):void
		{
			if(!Starling.context && !skipCreation){
				InitializationUtilG2D.initializeRenderers.add(buildG2DObject);
				return;
			}

			if(!skipCreation){
				if(!gpuObject){
					gpuObject = new Canvas();
				}
				
				if(_shapeDirty)
				{
					(gpuObject as Canvas).clear();
					(gpuObject as Canvas).beginFill(fillColor, fillAlpha);
					
					if(isSquare)
						(gpuObject as Canvas).drawRectangle(0, 0, size.x, size.y);
					else if(isCircle){
						var radiansX : Number = 180 * (Math.PI/180);
						var radiansY : Number = -90 * (Math.PI/180);
						var x : int = radius * Math.cos(radiansX);
						var y : int = radius * Math.sin(radiansY);
						(gpuObject as Canvas).drawCircle(-x*ResourceManager.scaleFactor, -y*ResourceManager.scaleFactor, radius*ResourceManager.scaleFactor);
					}
					(gpuObject as Canvas).endFill();
					_shapeDirty = false;
				}
			}
			super.buildG2DObject();
		}
		
		override protected function onRemove():void
		{
			super.onRemove();
			InitializationUtilG2D.initializeRenderers.remove(buildG2DObject);
		}
		
		override public function redraw():void
		{
			if(!this.isRegistered || !_size || _size.x == 0 || _size.y == 0 || (!isCircle && !isSquare) ) {
				return;
			}

			this.buildG2DObject();
		}
		
		/**
		 * @see Bitmap.smoothing 
		 */
		[EditorData(ignore="true")]
		public function set smoothing(value:Boolean):void
		{
			_smoothing = value;
		}
		public function get smoothing():Boolean
		{
			return _smoothing;
		}
	}
}