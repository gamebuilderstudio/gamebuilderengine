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
    
    import flash.display.BitmapData;
    
	public class SpriteSheetRenderer extends BitmapRenderer
	{
	    private var _spriteSheet:SpriteContainerComponent;
	    private var _setRegistration:Boolean = false;
		
	    public var spriteSheet:SpriteContainerComponent;
        public var spriteIndex:int = 0;
		public var directionReference:PropertyReference;

        protected function getCurrentFrame():BitmapData
        {
            if (!spriteSheet || !spriteSheet.isLoaded)
                return null;
            
            //if (!_setRegistration) for garnee's sake.
            // Our registration point is the center of a frame as specified by the spritesheet
	        if(spriteSheet && spriteSheet.isLoaded && spriteSheet.center)
            {
	            registrationPoint = spriteSheet.center.clone();
                registrationPoint.x *= -1;
                registrationPoint.y *= -1;
            }
	        
	        _setRegistration = true;
            
			if(directionReference)
				return spriteSheet.getFrame(spriteIndex, owner.getProperty(directionReference) as Number);
			else
            	return spriteSheet.getFrame(spriteIndex);
        }
        
        override public function onFrame(elapsed:Number) : void
        {
            super.onFrame(elapsed);
            
            // Update the bitmapData.
            var targetBD:BitmapData = getCurrentFrame();
            if(bitmapData != targetBD)
                bitmapData = targetBD;
        }
	}
}