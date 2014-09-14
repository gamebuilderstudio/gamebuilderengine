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
    import com.pblabs.starling2D.DisplayObjectRendererG2D;
    
    import flash.display.Graphics;
    import flash.display.Sprite;

    /**
     * Draw a simple shape, a box or a circle, with color. 
     */
    public class SimpleShapeRenderer extends DisplayObjectRendererG2D
    {
        public function SimpleShapeRenderer()
        {
            super();
        }

		protected var _isSquare:Boolean = false;
		protected var _isCircle:Boolean = true;
		protected var _radius:Number = 50;
		protected var _fillColor:uint = 0xFF00FF;
		protected var _fillAlpha:Number = 0.5;
		protected var _lineColor:uint = 0x00FF00;
		protected var _lineSize:Number = 0.5;
		protected var _lineAlpha:Number = 1;
		protected var _shape:Sprite;
		protected var _shapeDirty:Boolean = true;

        public function get lineAlpha():Number
        {
            return _lineAlpha;
        }

        /**
         * The opacity of the line. 
         */
        public function set lineAlpha(value:Number):void
        {
			if(_lineAlpha == value)
				return;
            _lineAlpha = value;
            _shapeDirty = true;
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
			if(_lineSize == value)
				return;
            _lineSize = value;
            _shapeDirty = true;
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
			if(_lineColor == value)
				return;
            _lineColor = value;
            _shapeDirty = true;
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
			if(_fillAlpha == value)
				return;
            _fillAlpha = value;
            _shapeDirty = true;
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
			if(_fillColor == value)
				return;
            _fillColor = value;
            _shapeDirty = true;
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
			if(_isCircle == value)
				return;
            _isCircle = value;
            _shapeDirty = true;
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
			if(_isSquare == value)
				return;
            _isSquare = value;
            _shapeDirty = true;
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
			if(_radius == value)
				return;
            _radius = value;
            _shapeDirty = true;
        }

        /**
         * Automatically called, but redraws the Sprite based on the user's
         * settings.
         */
        public function redraw():void
        {
			// Initialize displayObject to be a Sprite.
			if(!_shape)
				_shape = new Sprite();
			
            // Get references.
            var s:Sprite = _shape;
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
			if(!displayObject)
				displayObject = _shape;
			_shapeDirty = false;
        }
		
		override public function onFrame(elapsed:Number):void
		{
			super.onFrame(elapsed);
			
			if(_shapeDirty)
				redraw();

		}
		
		override protected function onAdd():void
		{
			redraw();
			super.onAdd();
		}
    }
}