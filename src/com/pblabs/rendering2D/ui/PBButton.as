/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.rendering2D.ui
{
    import flash.display.Sprite;
    import flash.geom.Rectangle;
    import flash.text.*;
    
    /**
     * Simple button for use in creating simple UIs.
     * 
     * Change properties and call refresh() for them to take effect.
     */
    public class PBButton extends Sprite
    {
        public function PBButton()
        {
            addChild(_label);
        }
        
        /**
         * Applies all changes and updates appearance of the button.
         * 
         * We have this as an explicit function call so that there
         * isn't any overhead if many properties are changed.
         */
        public function refresh():void
        {
            // Redraw our background.
            graphics.clear();
            graphics.beginFill(color);
            graphics.drawRoundRect(extents.x, extents.y, extents.width, extents.height, 16, 16);
            graphics.endFill();
            
            // Update the label position.
            _label.x = extents.x + 4;
            _label.y = extents.y + 4;
            _label.width = extents.width - 8;
            _label.height = extents.height - 8;
            _label.mouseEnabled = false;
            _label.cacheAsBitmap = true;
            
            // The text format.
            _labelStyle.size = fontSize;
            _labelStyle.color = fontColor;
            _labelStyle.align = TextFormatAlign.CENTER;
            _label.defaultTextFormat = _labelStyle;
            
            // And the label.
            _label.text = label;
            
            cacheAsBitmap = true;
        }
        
        /**
         * Color of button rectangle.
         */
        public var color:uint = 0xFF00FF;
        
        /**
         * Location and size of button, relative to parent.
         */
        public var extents:Rectangle = new Rectangle(0,0,100,100);
        
        /**
         * Text the button displays.
         */
        public var label:String = "Button";
        
        /**
         * Size of button label font.
         */
        public var fontSize:Number = 24;
        
        /**
         * Color of the button's label.
         */
        public var fontColor:uint = 0x00FF00;
        
        private var _labelStyle:TextFormat = new TextFormat("Helvetica");
        private var _label:TextField = new TextField();
    }
}