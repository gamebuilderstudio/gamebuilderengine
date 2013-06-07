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
	import com.pblabs.engine.PBUtil;
	import com.pblabs.engine.core.ObjectType;
	import com.pblabs.rendering2D.SWFSpriteRenderer;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	
	public class SWFSpriteRendererG2D extends SWFSpriteRenderer
	{
		public function SWFSpriteRendererG2D()
		{
			super();
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

		/**
		 * @inheritDoc
		 */
		override public function updateTransform(updateProps:Boolean = false):void
		{
			if(!gpuObject){
				return;
			}
			
			if(updateProps)
				updateProperties();
			
			gpuObject.pivotX = _registrationPoint.x;
			gpuObject.pivotY = _registrationPoint.y;
			gpuObject.x = this._position.x + _positionOffset.x;
			gpuObject.y = this._position.y + _positionOffset.y;
			gpuObject.rotation = PBUtil.getRadiansFromDegrees(_rotation) + _rotationOffset;
			gpuObject.scaleX = this.combinedScale.x;
			gpuObject.scaleY = this.combinedScale.y;
			gpuObject.alpha = this._alpha;
			gpuObject.blendMode = this._blendMode;
			gpuObject.visible = (alpha > 0);
			gpuObject.touchable = _mouseEnabled;

			_transformDirty = false;
		}

		override protected function buildG2DObject():void
		{
			if(!Starling.context){
				InitializationUtilG2D.initializeRenderers.add(buildG2DObject);
				return;
			}
			if(!_resource)
				return;
			
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

		override protected function paintMovieClipToBitmap(instance : DisplayObject):void
		{
			var texture : Texture = ResourceTextureManagerG2D.getTextureByKey( getTextureCacheKey() );
			if(texture)
				return;
			super.paintMovieClipToBitmap(instance);
		}

		protected function modifyTexture(data:Texture):Texture
		{
			return data;            
		}

		protected function getTextureCacheKey():String{
			if(!_resource)
				return null;
			return _resource.filename + _containingObjectName + combinedScale.x.toString() + combinedScale.y.toString();
		}

		override public function set mouseEnabled(value:Boolean):void
		{
			_mouseEnabled = value;
			
			if(!gpuObject) return;
			gpuObject.touchable = _mouseEnabled;
		}

		override public function set bitmapData(value:BitmapData):void
		{
			if (value === bitmap.bitmapData)
				return;
			
			// store orginal BitmapData so that modifiers can be re-implemented 
			// when assigned modifiers attribute later on.
			originalBitmapData = value;
			
			// check if we should do modification
			/*
			if (modifiers.length>0)
			{
				// apply all bitmapData modifiers
				bitmap.bitmapData = modify(originalBitmapData.clone());
				dataModified();			
			}	
			else						
			*/
				bitmap.bitmapData = value;
			
			// Due to a bug, this has to be reset after setting bitmapData.
			smoothing = _smoothing;
			
			buildG2DObject();
			
			_transformDirty = true;
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
					(gpuObject as Image).smoothing = TextureSmoothing.BILINEAR;
			}
		}
		
	}
}