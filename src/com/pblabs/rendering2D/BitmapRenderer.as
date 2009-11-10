package com.pblabs.rendering2D
{
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
        
        override public function set displayObject(value:DisplayObject):void
        {
            throw new Error("Cannot set displayObject in BitmapRenderer; it is always a Sprite containing a Bitmap.");
        }
        
        
        public function drawPixels(objectToScreen:Matrix, renderTarget:BitmapData):void
        {
            // Draw to the target.
            renderTarget.copyPixels(bitmap.bitmapData, bitmap.bitmapData.rect, objectToScreen.transformPoint(zeroPoint), null, null, true);
        }
        
        override public function pointOccupied(pos:Point):Boolean
        {            
            if(!bitmap || !bitmap.bitmapData)
                return false;
            
            // Make sure we're dealing in the same coordinate space as the provided position (screen global)
            //var localPos:Point = bitmap.globalToLocal(pos);
            //return bitmap.bitmapData.hitTest(zeroPoint, 0x01, localPos);
            
            // Figure local position.
            var localPos:Point = new Point(pos.x - (_position.x - _registrationPoint.x), pos.y - (_position.y - _registrationPoint.y));
            return bitmap.bitmapData.hitTest(zeroPoint, 0x01, localPos);
        }
        
        static protected const zeroPoint:Point = new Point();
    }
}