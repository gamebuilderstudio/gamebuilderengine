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
    import com.pblabs.engine.debug.Logger;
    
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.geom.Point;

    /**
     * Draw a simple shape, a box or a circle, with color. 
     */
    public class SimpleShapeRenderer extends DisplayObjectRenderer
    {
        public function SimpleShapeRenderer()
        {
            super();
            
            // Initialize displayObject to be a Sprite.
            displayObject = new Sprite();
            
            // Initial draw.
            redraw();
        }

        private var _radius:Number = 50;
        private var _isSquare:Boolean = false;
        private var _isCircle:Boolean = true;
        private var _fillColor:uint = 0xFF00FF;
        private var _fillAlpha:Number = 0.5;
        private var _lineColor:uint = 0x00FF00;
        private var _lineSize:Number = 0.5;
        private var _lineAlpha:Number = 1;

        public function get lineAlpha():Number
        {
            return _lineAlpha;
        }

        /**
         * The opacity of the line. 
         */
        public function set lineAlpha(value:Number):void
        {
            _lineAlpha = value;
            redraw();
        }

        public function get lineSize():Number
        {
            return _lineSize;
        }

        /**
         * Thickness of the line. If between 0 and 1 you get a hairline. 
         */
        public function set lineSize(value:Number):void
        {
            _lineSize = value;
            redraw();
        }

        public function get lineColor():uint
        {
            return _lineColor;
        }

        /**
         * Color of the line.
         */
        public function set lineColor(value:uint):void
        {
            _lineColor = value;
            redraw();
        }

        public function get fillAlpha():Number
        {
            return _fillAlpha;
        }

        /**
         * Opacity for the shape fill.
         */
        public function set fillAlpha(value:Number):void
        {
            _fillAlpha = value;
            redraw();
        }

        public function get fillColor():uint
        {
            return _fillColor;
        }

        /**
         * Fill shape with color.
         */
        public function set fillColor(value:uint):void
        {
            _fillColor = value;
            redraw();
        }

        public function get isCircle():Boolean
        {
            return _isCircle;
        }

        /**
         * If set, draw a circle.
         */
        public function set isCircle(value:Boolean):void
        {
            _isCircle = value;
            redraw();
        }

        public function get isSquare():Boolean
        {
            return _isSquare;
        }

        /**
         *  If set, draw a square.
         */
        public function set isSquare(value:Boolean):void
        {
            _isSquare = value;
            redraw();
        }

        public function get radius():Number
        {
            return _radius;
        }

        /**
         * The size of the shape in pixels.
         */
        public function set radius(value:Number):void
        {
            _radius = value;
            redraw();
        }

        /**
         * Automatically called, but redraws the Sprite based on the user's
         * settings.
         */
        public function redraw():void
        {
            // Get references.
            var s:Sprite = displayObject as Sprite;
            if(!s)
                throw new Error("displayObject null or not a Sprite!");
            var g:Graphics = s.graphics;
            
            // Don't forget to clear.
            g.clear();
            
            // Prep line/fill settings.
            g.lineStyle(_lineSize, _lineColor, _lineAlpha);
            g.beginFill(_fillColor, _fillAlpha);

            // Draw one or both shapes.
            if(isSquare)
                g.drawRect(-radius, -radius, radius*2, radius*2);
            
            if(isCircle)
                g.drawCircle(0, 0, radius);
            
            g.endFill();

            // Sanity check.
            if(!isCircle && !isSquare)
            {
                Logger.error(this, "redraw", "Neither square nor circle, what am I?");
            }               
        }
    }
}