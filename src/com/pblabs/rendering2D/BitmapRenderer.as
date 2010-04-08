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
    import com.pblabs.engine.core.ObjectType;
    import com.pblabs.engine.debug.Logger;
    
    import flash.display.*;
    import flash.geom.*;
    
    /**
     * Simple way to render a bitmap to a scene.
     */
    public class BitmapRenderer extends DisplayObjectRenderer implements ICopyPixelsRenderer
    {
        protected var bitmap:Bitmap = new Bitmap();
        protected var _smoothing:Boolean = false;
        
        public function BitmapRenderer()
        {
            super();
            
            _displayObject = new Sprite();
            (_displayObject as Sprite).addChild(bitmap);
            smoothing = true;
            bitmap.pixelSnapping = PixelSnapping.AUTO;
        }
        
        /**
         * @see Bitmap.smoothing 
         */
        [EditorData(ignore="true")]
        public function set smoothing(value:Boolean):void
        {
            _smoothing = value;
            bitmap.smoothing = value;
        }
        
        public function get smoothing():Boolean
        {
            return _smoothing;
        }
        
        /**
         * @see Bitmap.bitmapData 
         * @return 
         * 
         */
        [EditorData(ignore="true")]
        public function get bitmapData():BitmapData
        {
            return bitmap.bitmapData;
        }
        
        public function set bitmapData(value:BitmapData):void
        {
            if (value === bitmap.bitmapData)
                return;
            
            bitmap.bitmapData = value;
            
            // Due to a bug, this has to be reset after setting bitmapData.
            smoothing = _smoothing;
            _transformDirty = true;
        }
        
        [EditorData(ignore="true")]
        override public function set displayObject(value:DisplayObject):void
        {
            throw new Error("Cannot set displayObject in BitmapRenderer; it is always a Sprite containing a Bitmap.");
        }
        
        public function isPixelPathActive(objectToScreen:Matrix):Boolean
        {
            // No rotation/scaling/translucency/blend modes
            return (objectToScreen.a == 1 && objectToScreen.b == 0 && objectToScreen.c == 0 && objectToScreen.d == 1 && alpha == 1 && blendMode == BlendMode.NORMAL && (displayObject.filters.length == 0));
        }
        
        public function drawPixels(objectToScreen:Matrix, renderTarget:BitmapData):void
        {
            // Draw to the target.
            renderTarget.copyPixels(bitmap.bitmapData, bitmap.bitmapData.rect, objectToScreen.transformPoint(zeroPoint), null, null, true);
        }
        
        /**
        * @see Sprite.mouseEnabled
        */
        [EditorData(ignore="true")]
        public function set mouseEnabled(value:Boolean):void
        {
            (_displayObject as Sprite).mouseEnabled = value;
        }

        public function get mouseEnabled():Boolean
        {
            return (_displayObject as Sprite).mouseEnabled;
        }        
        
        override public function pointOccupied(worldPosition:Point, mask:ObjectType):Boolean
        {
            if(!bitmap || !bitmap.bitmapData)
                return false;
            
            // Figure local position.
            var localPos:Point = transformWorldToObject(worldPosition);
            return bitmap.bitmapData.hitTest(zeroPoint, 0x01, localPos);
        }
        
        static protected const zeroPoint:Point = new Point();
    }
}