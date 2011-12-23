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
    import com.pblabs.rendering2D.spritesheet.SpriteContainerComponent;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.geom.Point;
    
	public class SpriteSheetRenderer extends BitmapRenderer
	{		
	    public var spriteSheet:SpriteContainerComponent;
        public var spriteIndex:int = 0;
		public var directionReference:PropertyReference;
		public var overrideSizePerFrame : Boolean = true;

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
		
        protected function getCurrentFrame():BitmapData
        {
            if (!spriteSheet || !spriteSheet.isLoaded)
                return null;
            
			
			var curFrame:BitmapData;
			if(directionReference)
				curFrame = spriteSheet.getFrame(spriteIndex, owner.getProperty(directionReference) as Number);
			else
				curFrame = spriteSheet.getFrame(spriteIndex);
			
            // Our registration point is the center of a frame as specified by the spritesheet
	        if(spriteSheet && spriteSheet.isLoaded && spriteSheet.center)
			{
	            registrationPoint = spriteSheet.center.clone();					
			}
			if(curFrame && this.size && this.sizeProperty && overrideSizePerFrame && (this.size.x != curFrame.width || this.size.y != curFrame.height))
			{
				var newSize : Point = new Point(curFrame.width, curFrame.height);
				this.size = newSize;
				this.owner.setProperty( this.sizeProperty, newSize);
			}else if(overrideSizePerFrame){
				this.size =  new Point(curFrame.width, curFrame.height);
			}
			
			return curFrame;
            
        }
						
		protected override function dataModified():void
		{
			// set the registration (alignment) point to the sprite's center
			if (spriteSheet.centered)
			  registrationPoint = new Point(bitmapData.width/2,bitmapData.height/2);
		}
		
		protected override function modify(data:BitmapData):BitmapData
		{
			// this function is overridden so spriteIndex can be passed to 
			// the applied modifiers
			for (var m:int = 0; m<modifiers.length; m++)
				data = (modifiers[m] as Modifier).modify(data, spriteIndex, spriteSheet.frameCount);
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