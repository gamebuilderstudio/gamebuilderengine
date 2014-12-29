/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.rendering2D
{
    import com.pblabs.engine.entity.PropertyReference;
    import com.pblabs.rendering2D.modifier.Modifier;
    import com.pblabs.rendering2D.spritesheet.ISpriteSheet;
    
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.geom.Point;
    
	public class SpriteSheetRenderer extends BitmapRenderer implements ISpriteSheetRenderer
	{		
		public var spriteSheetProperty : PropertyReference;
		public var directionReference:PropertyReference;

		protected var currentSpatialName : String;
		protected var currentSpatialRef : PropertyReference;
		protected var _spriteSheet:ISpriteSheet;
		protected var _spriteIndex:int = 0;
		protected var _overrideSizePerFrame : Boolean = true;

		override public function set registrationPoint(value:Point):void
		{
			super.registrationPoint = value;
			if(_spriteSheet)
				_spriteSheet.center = _registrationPoint;
		}
		
		public function get spriteSheet():ISpriteSheet { return _spriteSheet; }
		public function set spriteSheet(val : ISpriteSheet):void { 
			_spriteSheet = val; 
		}

		public function get spriteIndex():int { return _spriteIndex; }
		public function set spriteIndex(val : int):void { _spriteIndex = val; }

		public function get overrideSizePerFrame():Boolean { return _overrideSizePerFrame; }
		public function set overrideSizePerFrame(val : Boolean):void { _overrideSizePerFrame = val; }

		override public function get displayObject():DisplayObject
		{
			if(!_displayObject)
			{
				bitmapData = getCurrentFrame();
			}
			return super.displayObject;
		}
		override protected function onAdd() : void
		{
			super.onAdd();
			bitmapData = getCurrentFrame();
		}
		
		override protected function onReset():void
		{
			super.onReset();
			if(spriteSheetProperty && !spriteSheet)
				spriteSheet = this.owner.getProperty( spriteSheetProperty ) as ISpriteSheet;
			if(spriteSheet && spriteSheet.isDestroyed)
				spriteSheet = null;
			bitmapData = getCurrentFrame();
		}
		
        protected function getCurrentFrame():BitmapData
        {
            if (!_spriteSheet || !_spriteSheet.isLoaded)
                return null;
            
			
			var curFrame:BitmapData;
			if(directionReference)
				curFrame = _spriteSheet.getFrame(_spriteIndex, owner.getProperty(directionReference) as Number);
			else
				curFrame = _spriteSheet.getFrame(_spriteIndex);
			
			if(!curFrame)
				return null;
			
            // Our registration point is the center of a frame as specified by the spritesheet
	        if(_spriteSheet && _spriteSheet.isLoaded && _spriteSheet.center)
			{
	            registrationPoint = _spriteSheet.center.clone();					
			}
			if(curFrame && this.size && this.sizeProperty && _overrideSizePerFrame && (this.size.x != curFrame.width || this.size.y != curFrame.height))
			{
				var newSize : Point = new Point(curFrame.width, curFrame.height);
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
			}else if(_overrideSizePerFrame && (this.size.x != curFrame.width || this.size.y != curFrame.height)){
				this.size =  new Point(curFrame.width, curFrame.height);
			}
			
			return curFrame;
            
        }
						
		protected override function dataModified():void
		{
			// set the registration (alignment) point to the sprite's center
			if (_spriteSheet.centered)
			  registrationPoint = new Point(bitmapData.width/2,bitmapData.height/2);
		}
		
		protected override function modify(data:BitmapData):BitmapData
		{
			// this function is overridden so spriteIndex can be passed to 
			// the applied modifiers
			for (var m:int = 0; m<modifiers.length; m++)
				data = (modifiers[m] as Modifier).modify(data, _spriteIndex, _spriteSheet.frameCount);
			return data;            
		}
				
        override public function onFrame(elapsed:Number) : void
        {
            // Update the bitmapData.
            var targetBD:BitmapData = getCurrentFrame();
			if(bitmapData != targetBD && targetBD!=null)
				bitmapData = targetBD;
			
			if (targetBD!=null)
			  super.onFrame(elapsed);
        }
	}
}