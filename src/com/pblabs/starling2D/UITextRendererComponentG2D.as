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
	import com.pblabs.rendering2D.UITextRendererComponent;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.TextureSmoothing;
	
	public class UITextRendererComponentG2D extends UITextRendererComponent
	{
		public function UITextRendererComponentG2D()
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

		override protected function onAdd():void
		{
			super.onAdd();
			Starling.current.stage.addEventListener(TouchEvent.TOUCH, onStageTouch);
			
		}

		override protected function onRemove():void
		{
			super.onRemove();
			Starling.current.stage.removeEventListener(TouchEvent.TOUCH, onStageTouch);
		}

		override protected function buildG2DObject():void
		{
			if(!Starling.context){
				InitializationUtilG2D.initializeRenderers.add(buildG2DObject);
				return;
			}
			
			if(!gpuObject){
				//Create GPU Renderer Object
				gpuObject = new Image( ResourceTextureManagerG2D.getTextureForBitmapData( this.bitmap.bitmapData ) );
			}else{
				if(( gpuObject as Image).texture)
					( gpuObject as Image).texture.dispose();
				( gpuObject as Image).texture = ResourceTextureManagerG2D.getTextureForBitmapData( this.bitmap.bitmapData );
				( gpuObject as Image).readjustSize();
			}
			smoothing = _smoothing;
			super.buildG2DObject();
		}
		
		protected function onStageTouch(event : TouchEvent):void
		{
			var touch : Touch = event.getTouch(Starling.current.stage, TouchPhase.BEGAN);
			if(!touch)
				return;
			_stagePoint.setTo( touch.globalX, touch.globalY );
			toggleInputDisplay();
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
					(gpuObject as Image).smoothing = TextureSmoothing.TRILINEAR;
			}
		}
	}
}