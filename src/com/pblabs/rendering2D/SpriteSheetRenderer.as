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
    import com.pblabs.rendering2D.spritesheet.SpriteContainerComponent;
    
    import flash.display.BitmapData;
    import flash.geom.Point;
    
	public class SpriteSheetRenderer extends BitmapRenderer
	{
	    private var _spriteSheet:SpriteContainerComponent;
	    private var _setRegistration:Boolean = false;
	    
	    public var spriteSheet:SpriteContainerComponent;
        public var spriteIndex:int = 0;

        protected function getCurrentFrame():BitmapData
        {
            if (!spriteSheet || !spriteSheet.isLoaded)
                return null;
            
            if (!_setRegistration)
            {
	            // Our registration point is the center of a frame as specified by the spritesheet
    	        if (spriteSheet && spriteSheet.isLoaded && spriteSheet.center)
    	            registrationPoint = spriteSheet.center.clone();
    	        
    	        _setRegistration = true;
            }
            
            return spriteSheet.getFrame(spriteIndex);
        }
        
        override public function onFrame(elapsed:Number) : void
        {
            super.onFrame(elapsed);
            
            // Update the bitmapData.
            var targetBD:BitmapData = getCurrentFrame();
            if(bitmapData !== targetBD)
                bitmapData = targetBD;
        }
	}
}