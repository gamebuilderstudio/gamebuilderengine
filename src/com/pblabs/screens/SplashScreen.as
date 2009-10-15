package com.pblabs.screens
{
    import com.pblabs.engine.debug.*;
    import com.pblabs.engine.resource.*;
    
    import flash.display.*;
    import flash.events.*;

    /**
     * Simple screen to display an image, and advance to another screen
     * when the user clicks.
     */ 
	public class SplashScreen extends BaseScreen
	{
        /**
         * See class description. 
         * @param image File to display as splash screen.
         * @param nextScreen Name of screen to go to on user input.
         * 
         */
		public function SplashScreen(image:String, nextScreen:String)
		{
            // Note where we're going next.
            next = nextScreen;

            // Set up clicks.
            addEventListener(MouseEvent.CLICK, 
                function(e:MouseEvent):void 
                {
                    ScreenManager.instance.goto(next);
                }
            );
            
            // Load the image.
            ResourceManager.instance.load(image, ImageResource, onImageSucceed, onImageFail);
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
        
        public var next:String = "";
	}
}