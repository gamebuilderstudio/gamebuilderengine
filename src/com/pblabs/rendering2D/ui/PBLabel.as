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
     * Simple label for simple UIs.
     * 
     * Set properties and call refresh().
     */
    public class PBLabel extends Sprite
    {
        public function PBLabel()
        {
            addChild(_label);

            mouseEnabled = false;
        }
        
        /**
         * Applies all changes and updates appearance of the label.
         * 
         * We have this as an explicit function call so that there
         * isn't any overhead if many properties are changed.
         */
        public function refresh():void
        {
            // Update the label position.
            _label.x = extents.x;
            _label.y = extents.y;
            _label.width = extents.width;
            _label.height = extents.height;
            _label.mouseEnabled = false;
            _label.multiline = true;
            _label.wordWrap = true;
            _label.autoSize = TextFieldAutoSize.LEFT;
            
            // The text format.
            _labelStyle.size = fontSize;
            _labelStyle.color = fontColor;
            _labelStyle.align = fontAlign;
            _labelStyle.bold = fontBold;
            _label.defaultTextFormat = _labelStyle;
            
            // And the caption.
            _label.text = caption;
        }
        
        /**
         * Location and size of label, relative to parent.
         */
        public var extents:Rectangle = new Rectangle(0,0,100,100);
        
        /**
         * Text the label displays.
         */
        public var caption:String = "Label";

        /**
         * Size of the label's font. 
         */        
        public var fontSize:Number = 24;

        /**
         * Is the label's font bold?
         */
        public var fontBold:Boolean = false;

        /**
         * Color of the label's caption.
         */
        public var fontColor:uint = 0xFFFFFF;

        /**
         * Alignment of the label's text.
         */
        public var fontAlign:String = TextFormatAlign.LEFT;
        
        private var _labelStyle:TextFormat = new TextFormat("Helvetica");
        private var _label:TextField = new TextField();
    }
}