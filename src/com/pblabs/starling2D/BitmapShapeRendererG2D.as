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
	import com.pblabs.rendering2D.BitmapShapeRenderer;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	
	public class BitmapShapeRendererG2D extends BitmapShapeRenderer
	{
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
				try{
					if((!bitmap || !bitmap.bitmapData) && !texture)
					{
						return;
					}
				}catch(e : Error){
					return;
				}
				
				if(!gpuObject){
					var texture : Texture = ResourceTextureManagerG2D.getTextureByKey( textureCacheKey );
					if(texture)
					{
						gpuObject = new Image(texture);
					}else{
						//Create GPU Renderer Object
						gpuObject = new Image(ResourceTextureManagerG2D.getTextureForBitmapData( this.bitmap.bitmapData, textureCacheKey ));
					}
				}else if(_shapeDirty){
					if((gpuObject as Image).texture)
						( gpuObject as Image).texture.dispose();
				
					(gpuObject as Image).texture = texture = ResourceTextureManagerG2D.getTextureForBitmapData(this.bitmap.bitmapData, textureCacheKey);
					(gpuObject as Image).readjustSize();
				}
				smoothing = _smoothing;
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

			if(!ResourceTextureManagerG2D.isATextureCachedWithKey( textureCacheKey ) || _shapeDirty){
				
				if(bitmap){
					if(bitmap.bitmapData)
						bitmap.bitmapData.dispose();
					bitmap.bitmapData = null;
				}
				
				if(!_shape)
					_shape = new Sprite();
				
				// Get references.
				var s:Sprite = _shape;
				if(!s)
					throw new Error("displayObject null or not a Sprite!");
				var g:Graphics = s.graphics;
				
				// Don't forget to clear.
				g.clear();
				
				// Prep line/fill settings.
				g.lineStyle(lineSize, lineColor, lineAlpha);
				g.beginFill(fillColor, fillAlpha);
				
				// Draw one or both shapes.
				if(isSquare)
					g.drawRect(0, 0, size.x*ResourceManager.scaleFactor, size.y*ResourceManager.scaleFactor);
				
				if(isCircle){
					var radiansX : Number = 180 * (Math.PI/180);
					var radiansY : Number = -90 * (Math.PI/180);
					var x : int = radius * Math.cos(radiansX);
					var y : int = radius * Math.sin(radiansY);
					g.drawCircle(-x*ResourceManager.scaleFactor, -y*ResourceManager.scaleFactor, radius*ResourceManager.scaleFactor);
				}
				
				g.endFill();
				
				if(!bitmap){
					bitmap = new Bitmap();
					bitmap.pixelSnapping = PixelSnapping.AUTO;
					bitmap.blendMode = this._blendMode;
				}
				
				if(isCircle || isSquare){
					var bounds : Rectangle = s.getBounds( s );
					var m : Matrix = new Matrix();
					//_registrationPoint = new Point(-bounds.topLeft.x, -bounds.topLeft.y);
					bitmap.bitmapData = new BitmapData(bounds.width, bounds.height, true, 0x000000);
					bitmap.bitmapData.draw(s,m, s.transform.colorTransform, s.blendMode );
					bitmap.smoothing = this._smoothing;
				}
			}
			this.buildG2DObject();
			_shapeDirty = false;
		}
		
		protected function get textureCacheKey():String{
			return _isSquare + ":" + _isCircle + ":" + _radius + ":" + _fillColor + ":" + _fillAlpha + ":" + _lineColor + ":" + _lineSize + ":" + _lineAlpha + ":" + "_"+_size.x +","+_size.y+"_";
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