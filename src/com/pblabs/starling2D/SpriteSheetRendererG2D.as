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
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.rendering2D.ISpatialObject2D;
	import com.pblabs.rendering2D.ISpriteSheetRenderer;
	import com.pblabs.rendering2D.spritesheet.ISpriteSheet;
	import com.pblabs.starling2D.spritesheet.ISpriteSheetG2D;
	
	import flash.geom.Point;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.textures.Texture;
	
	/**
	 * SpriteSheet Render Component that will load textures from a Starling ISpriteSheetG2D class onto the GPU object.
	 */ 
	public class SpriteSheetRendererG2D extends BitmapRendererG2D implements ISpriteSheetRenderer
	{
		public var directionReference:PropertyReference;
		
		protected var currentSpatialName : String;
		protected var currentSpatialRef : PropertyReference;
		protected var currentTexture : Texture;
		protected var _spriteSheetProperty : PropertyReference;
		protected var _spriteSheet:ISpriteSheetG2D;
		protected var _spriteIndex:int = 0;
		protected var _overrideSizePerFrame : Boolean = true;
		
		private var _scrachPoint : Point = new Point();

		public function SpriteSheetRendererG2D()
		{
			super();
		}

		override public function set registrationPoint(value:Point):void
		{
			super.registrationPoint = value;
			if(_spriteSheet)
				_spriteSheet.center = _registrationPoint;
		}

		public function get spriteSheetProperty():PropertyReference { return _spriteSheetProperty; }
		public function set spriteSheetProperty(val : PropertyReference):void { 
			_spriteSheetProperty = val; 
		}

		public function get spriteSheet():ISpriteSheet { return _spriteSheet; }
		public function set spriteSheet(obj : ISpriteSheet):void { _spriteSheet = obj as ISpriteSheetG2D; }
		
		public function get spriteIndex():int { return _spriteIndex; }
		public function set spriteIndex(val : int):void { _spriteIndex = val; }

		public function get overrideSizePerFrame():Boolean { return _overrideSizePerFrame; }
		public function set overrideSizePerFrame(val : Boolean):void { _overrideSizePerFrame = val; }
		
		override public function onFrame(elapsed:Number) : void
		{
			// Update the bitmapData.
			var newTexture:Texture = getCurrentTexture();
			if(newTexture != null && currentTexture != newTexture){
				currentTexture = newTexture;
				buildG2DObject();
			}
			
			if (currentTexture!=null)
				super.onFrame(elapsed);
		}

		protected function getCurrentTexture():Texture
		{
			if (!_spriteSheet || !_spriteSheet.isLoaded)
				return null;
			
			
			var tempTexture : Texture;
			if(directionReference)
				tempTexture = modifyTexture(_spriteSheet.getTexture(_spriteIndex, owner.getProperty(directionReference) as Number));
			else
				tempTexture = modifyTexture(_spriteSheet.getTexture(_spriteIndex));
			
			if(!tempTexture)
				return null;
			
			// Our registration point is the center of a frame as specified by the spritesheet
			if(_spriteSheet && _spriteSheet.isLoaded && _spriteSheet.center)
			{
				_scrachPoint.copyFrom(_spriteSheet.center);
				registrationPoint = _scrachPoint;					
			}
			if (_spriteSheet.centered)
				registrationPoint = new Point(tempTexture.width/2,tempTexture.height/2);
			if(tempTexture && this.size && this.sizeProperty && _overrideSizePerFrame && (this.size.x != tempTexture.width || this.size.y != tempTexture.height))
			{
				var newSize : Point = new Point(tempTexture.width, tempTexture.height);
				this.size = newSize;
				
				if(!currentSpatialName || this.sizeProperty.property.indexOf( currentSpatialName ) == -1){
					var spatialParts : Array = this.sizeProperty.property.split(".");
					spatialParts.pop();
					var tmpSpatialName : String = spatialParts.join(".");
					if(currentSpatialName != tmpSpatialName)
					{
						currentSpatialName = tmpSpatialName;
						currentSpatialRef = new PropertyReference(currentSpatialName);
					}
				}
				
				var spatial : ISpatialObject2D = this.owner.getProperty( currentSpatialRef ) as ISpatialObject2D;
				if(spatial && spatial.spriteForPointChecks == this){
					this.owner.setProperty( this.sizeProperty, newSize);
				}
			}else if(_overrideSizePerFrame && (this.size.x != tempTexture.width || this.size.y != tempTexture.height)){
				this.size =  new Point(tempTexture.width, tempTexture.height);
			}
			
			return tempTexture;
			
		}
		
		protected override function dataModified():void
		{
			// set the registration (alignment) point to the sprite's center
			/*if (_spriteSheet.centered)
				registrationPoint = new Point(currentTexture.width/2,currentTexture.height/2);*/
		}
		
		protected override function modifyTexture(data:Texture):Texture
		{
			// this function is overridden so spriteIndex can be passed to 
			// the applied modifiers
			/*for (var m:int = 0; m<modifiers.length; m++)
				data = (modifiers[m] as Modifier).modify(data, _spriteIndex, _spriteSheet.frameCount);
			return data;*/     
			return data;
		}
		
		override protected function onAdd() : void
		{
			super.onAdd();
			
			buildG2DObject();
		}
		
		override protected function onRemove():void
		{
			super.onRemove();
			
			currentTexture = null;
			InitializationUtilG2D.initializeRenderers.remove(buildG2DObject);
		}

		override protected function onReset():void
		{
			super.onReset();
			if(spriteSheetProperty && !spriteSheet)
				spriteSheet = this.owner.getProperty( spriteSheetProperty ) as ISpriteSheet;
			if(spriteSheet && spriteSheet.isDestroyed)
				spriteSheet = null;
			currentTexture = getCurrentTexture();
			buildG2DObject();
		}

		override protected function buildG2DObject(skipCreation : Boolean = false):void
		{
			if(!Starling.context && !skipCreation){
				InitializationUtilG2D.initializeRenderers.add(buildG2DObject);
				return;
			}
			if(!skipCreation){
				if(!gpuObject && currentTexture){
					//Create GPU Renderer Object
					gpuObject = new Image(currentTexture);
				}else if(gpuObject && currentTexture){
					(gpuObject as Image).texture = currentTexture;
					(gpuObject as Image).readjustSize();
				}
				smoothing = _smoothing;
				skipCreation = true;
			}
			super.buildG2DObject(skipCreation);
		}
		
	}
}