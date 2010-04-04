/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.screens
{
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.engine.resource.ImageResource;
    
    import flash.display.*;
    import flash.events.*;
    
    /**
     * Simple screen to display an image. Useful for building other screens.
     */ 
    public class ImageScreen extends BaseScreen
    {
        /**
         * See class description. 
         * @param image File to display as splash screen.
         */
        public function ImageScreen(image:String)
        {
            // Load the image.
            PBE.resourceManager.load(image, ImageResource, onImageSucceed, onImageFail);
        }
        
        private function onImageSucceed(i:ImageResource):void
        {
            // Display the bitmap.
            cacheAsBitmap = true;
            graphics.clear();
            graphics.beginBitmapFill(i.image.bitmapData);
            graphics.drawRect(0, 0, i.image.bitmapData.width, i.image.bitmapData.height);
            graphics.endFill();
        }
        
        private function onImageFail(i:ImageResource):void
        {
            Logger.print(this, "Failed to load image '" + i.filename + "'");
        }
    }
}