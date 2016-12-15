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
	import com.pblabs.rendering2D.BitmapRenderer;
	import com.pblabs.starling2D.modifier.ModifierG2D;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.filters.FilterChain;
	import starling.textures.TextureSmoothing;
	
	public class BitmapRendererG2D extends BitmapRenderer
	{
		public function BitmapRendererG2D()
		{
			super();
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
				if(!originalBitmapData) return;
				if(!gpuObject){
					//Create GPU Renderer Object
					gpuObject = new Image( ResourceTextureManagerG2D.getTextureForBitmapData( originalBitmapData ) );
				}else{
					if(( gpuObject as Image).texture)
						( gpuObject as Image).texture.dispose();
					( gpuObject as Image).texture = ResourceTextureManagerG2D.getTextureForBitmapData( originalBitmapData );
					( gpuObject as Image).readjustSize();
				}
				smoothing = _smoothing;
				skipCreation = true;
			}
			modifyG2D(gpuObject);
			super.buildG2DObject(skipCreation);
			_imageDataDirty = false;
		}
		
		protected function modifyG2D(object:DisplayObject):void
		{
			if(!object) return;
			
			if(object.filter)
				object.filter.dispose();
			if(modifiers.length > 0)
				object.filter = new FilterChain();
			// loop and apply modifiers
			for (var m:int = 0; m<modifiers.length; m++)
				(modifiers[m] as ModifierG2D).modify(object);
		}

		override public function set modifiers(value:Array):void
		{
			_modifiers = value;
			if (gpuObject)
			{
				modifyG2D(gpuObject);
				dataModified();			
			}				
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
			
			if(value != originalBitmapData){
				// store orginal BitmapData so that modifiers can be re-implemented 
				// when assigned modifiers attribute later on.
				originalBitmapData = value;
				_imageDataDirty = true;
			}

			bitmap.bitmapData = value;
			
			// Due to a bug, this has to be reset after setting bitmapData.
			_transformDirty = true;
			buildG2DObject();
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
				if(!_smoothing && gpuObject is Image)
					(gpuObject as Image).textureSmoothing = TextureSmoothing.NONE;
				else if(gpuObject is Image)
					(gpuObject as Image).textureSmoothing = TextureSmoothing.TRILINEAR;
			}
		}
	}
}