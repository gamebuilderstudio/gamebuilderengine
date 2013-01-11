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
	import com.pblabs.rendering2D.BitmapShapeRenderer;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.geom.Point;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	
	public class BitmapShapeRendererG2D extends BitmapShapeRenderer
	{
		public function BitmapShapeRendererG2D()
		{
			_displayObject = null;

			_smoothing = false;
			bitmap.pixelSnapping = PixelSnapping.AUTO;
			
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

		override protected function buildG2DObject():void
		{
			if(!Starling.context){
				InitializationUtilG2D.initializeRenderers.add(buildG2DObject);
				return;
			}

			try{
				if(!this.isRegistered || !bitmap || !bitmap.bitmapData)
				{
					return;
				}
			}catch(e : Error){
				return;
			}
			
			var texture : Texture = ResourceTextureManagerG2D.getTextureByKey( getTextureCacheKey() );
			if(!gpuObject){
				if(texture)
				{
					gpuObject = new Image(texture);
				}else{
					//Create GPU Renderer Object
					gpuObject = new Image(ResourceTextureManagerG2D.getTextureForBitmapData( this.bitmap.bitmapData, getTextureCacheKey() ));
				}
			}else{
				if(( gpuObject as Image).texture)
					( gpuObject as Image).texture.dispose();
				texture = (gpuObject as Image).texture = ResourceTextureManagerG2D.getTextureForBitmapData(this.bitmap.bitmapData, getTextureCacheKey());
				( gpuObject as Image).readjustSize();
			}
			smoothing = _smoothing;
			super.buildG2DObject();
		}
		
		override protected function onRemove():void
		{
			super.onRemove();
			InitializationUtilG2D.initializeRenderers.remove(buildG2DObject);
		}
		
		override public function redraw():void
		{
			super.redraw();
			
			buildG2DObject();
		}
		
		protected function getTextureCacheKey():String{
			return _isSquare + ":" + _isCircle + ":" + _radius + ":" + _fillColor + ":" + _fillAlpha + ":" + _lineColor + ":" + _lineSize + ":" + _lineAlpha + ":"
		}
		
		/**
		 * @see Bitmap.smoothing 
		 */
		[EditorData(ignore="true")]
		override public function set smoothing(value:Boolean):void
		{
			super.smoothing = value;
			if(gpuObject)
			{
				if(!_smoothing)
					(gpuObject as Image).smoothing = TextureSmoothing.NONE;
				else
					(gpuObject as Image).smoothing = TextureSmoothing.TRILINEAR;
			}
		}
	}
}