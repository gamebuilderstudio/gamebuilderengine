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
    import com.pblabs.engine.debug.*;
    import com.pblabs.engine.resource.*;
    
    import flash.display.*;
    import flash.events.*;

    /**
     * Simple screen to display an image, and advance to another screen
     * when the user clicks.
     */ 
	public class SplashScreen extends ImageScreen
	{
        /**
         * See class description. 
         * @param image File to display as splash screen.
         * @param nextScreen Name of screen to go to on user input.
         * 
         */
		public function SplashScreen(image:String, nextScreen:String)
		{
            // Set up the image.
            super(image);
            
            // Note where we're going next.
            next = nextScreen;

            // Set up clicks.
            addEventListener(MouseEvent.CLICK, 
                function(e:MouseEvent):void 
                {
                    ScreenManager.instance.goto(next);
                }
            );
 		}
        
        public var next:String = "";
	}
}