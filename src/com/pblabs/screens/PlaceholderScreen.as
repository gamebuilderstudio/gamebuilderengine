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
    import com.pblabs.rendering2D.ui.PBLabel;
    
    import flash.geom.*;

    /**
     * Simple placeholder screen which has a background fill and a caption in 
     * the top left. Useful for blocking out your screen flow. 
     */
	public class PlaceholderScreen extends BaseScreen
	{
		public function PlaceholderScreen(caption:String, bgColor:uint)
		{
		    super();
            
            addChild(captionLabel);
            captionLabel.extents = new Rectangle(0, 0, 250, 50);
            captionLabel.fontBold = true;
            captionLabel.caption = caption;
            captionLabel.fontColor = 0xFFFFFF;
            captionLabel.refresh();
            
            fillColor = bgColor;
		}
        
        public override function onShow():void
        {
            // Draw a background that fills the screen.
            graphics.clear();
            graphics.beginFill(fillColor);
            graphics.drawRoundRect(0, 0, PBE.mainStage.stageWidth, PBE.mainStage.stageHeight, 16, 16);
            graphics.endFill();
        }
        
        public var fillColor:uint = Math.random() * 0xFFFFFF;
        public var captionLabel:PBLabel = new PBLabel();
	}
}