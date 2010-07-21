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
    import com.pblabs.rendering2D.spritesheet.SpriteContainerComponent;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.geom.Point;
    
	public class SpriteSheetRenderer extends BitmapRenderer
	{		
	    public var spriteSheet:SpriteContainerComponent;
        public var spriteIndex:int = 0;
		public var directionReference:PropertyReference;

        protected function getCurrentFrame():BitmapData
        {
            if (!spriteSheet || !spriteSheet.isLoaded)
                return null;
            
            // Our registration point is the center of a frame as specified by the spritesheet
	        if(spriteSheet && spriteSheet.isLoaded && spriteSheet.center)
			{
	            registrationPoint = spriteSheet.center.clone();					
			}
            
			if(directionReference)
				return spriteSheet.getFrame(spriteIndex, owner.getProperty(directionReference) as Number);
			else
            	return spriteSheet.getFrame(spriteIndex);
        }
						
		protected override function dataModified():void
		{
			// set the registration (alignment) point to the sprite's center
			if (spriteSheet.centered)
			  registrationPoint = new Point(bitmapData.width/2,bitmapData.height/2);
		}
				
        override public function onFrame(elapsed:Number) : void
        {
            // Update the bitmapData.
            var targetBD:BitmapData = getCurrentFrame();
			if(bitmapData != targetBD)
				bitmapData = targetBD;
			
            super.onFrame(elapsed);
															
        }
	}
}