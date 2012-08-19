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
	
	public class BitmapShapeRendererG2D extends BitmapShapeRenderer
	{
		public function BitmapShapeRendererG2D()
		{
			_displayObject = null;

			smoothing = true;
			bitmap.pixelSnapping = PixelSnapping.AUTO;
			
			lineSize = 0;
			lineAlpha = 0;
			redraw();
		}
		
		override public function pointOccupied(worldPosition:Point, mask:ObjectType):Boolean
		{
			if (!gpuObject || !scene)
				return false;
			
			// This is the generic version, which uses hitTestPoint. hitTestPoint
			// takes a coordinate in screen space, so do that.
			worldPosition = scene.transformWorldToScreen(worldPosition);
			
			return gpuObject.hitTest(worldPosition) ? true : false;
		}

		override protected function buildG2DObject():void
		{
			if(!Starling.context){
				InitializationUtilG2D.initializeRenderers.add(buildG2DObject);
				return;
			}

			try{
				if(!bitmap || !bitmap.bitmapData || !bitmap.bitmapData.width)
				{
					redraw();
				}
			}catch(e : Error){
				redraw();
				return;
			}
			
			var texture : Texture = ResourceTextureManagerG2D.getTextureByKey( getTextureCacheKey() );
			if(!gpuObject){
				if(texture)
				{
					gpuObject = new Image(Texture.fromTexture(texture));
				}else{
					//Create GPU Renderer Object
					gpuObject = Image.fromBitmap( this.bitmap );
					ResourceTextureManagerG2D.mapTextureWithKey( (gpuObject as Image).texture, getTextureCacheKey());
				}
			}else{
				if(( gpuObject as Image).texture)
					( gpuObject as Image).texture.dispose();
				texture = (gpuObject as Image).texture = Texture.fromBitmap( this.bitmap );
				ResourceTextureManagerG2D.mapTextureWithKey( texture, getTextureCacheKey());
			}
			super.buildG2DObject();
		}
		
		override public function redraw():void
		{
			super.redraw();
			
			buildG2DObject();

			if(bitmap && bitmap.bitmapData)
				bitmap.bitmapData.dispose();
		}
		
		protected function getTextureCacheKey():String{
			return _isSquare + ":" + _isCircle + ":" + _radius + ":" + _fillColor + ":" + _fillAlpha + ":" + _lineColor + ":" + _lineSize + ":" + _lineAlpha + ":"
		}
	}
}