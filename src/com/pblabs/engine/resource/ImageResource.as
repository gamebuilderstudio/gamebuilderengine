/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.resource
{
    import com.pblabs.engine.PBE;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    
    [EditorData(extensions="jpg,png,gif")]
    
    /**
     * This is a Resource subclass for image data. It allows you to load an image
     * file format supported by Flash (JPEG, PNG, or GIF) and access it as a 
     * BitmapData or Bitmap. 
     */
    public class ImageResource extends Resource
    {
        /**
         * Once the resource has succesfully loaded, this contains a Bitmap representing
         * the loaded image. Because Bitmaps cannot be shared, this makes a new
         * Bitmap every time it is called.
         */
        public function get image():Bitmap
        {
            // if we have BitmapData but no Bitmap yet .. create one..
            if (_bitmapData != null)
                return new Bitmap(_bitmapData);
            return null;
        }
        
        /**
         * Get the raw BitmapData that was loaded.
         */
        public function  get bitmapData():BitmapData
        {
            return _bitmapData;
        }
        
        override public function initialize(data:*):void
        {        	
            if (data is Bitmap)
            {
                // Directly load embedded resources if they gave us a Bitmap.
                onContentReady(data.bitmapData);
                onLoadComplete();
                return;
            }
            else if (data is BitmapData)
            {
                // If they gave us a BitmapData object create a new Bitmap from that
                onContentReady(data as BitmapData);
                onLoadComplete();  
                return;          	
            }
            else if (data is DisplayObject)
            {
                var dObj:DisplayObject = data as DisplayObject;
                
                // get sprite's targetSpace
                var targetSpace:DisplayObject;
                if(dObj.parent)
                    targetSpace = dObj.parent;
                else
                    targetSpace = PBE.mainStage;
                
                // get sprite's rectangle 
                var spriteRect:Rectangle = dObj.getBounds(targetSpace);
                
                // create transform matrix for drawing this sprite;
                var m:Matrix = new Matrix();
                m.translate(spriteRect.x*-1, spriteRect.y*-1);            	  
                
                // If they gave us a Sprite draw this onto a transparent filled BitmapData object
                var bmd:BitmapData = new BitmapData(spriteRect.width,spriteRect.height,true,0x000000);
                bmd.draw(dObj, m);
                
                // Use the BitmapData to create a new Bitmap for this ImageResource 
                onContentReady(bmd);
                onLoadComplete();
                return;            	
            }
            
            // Otherwise it must be a ByteArray, pass it over to the normal path.
            super.initialize(data);
        }
        
        /**
         * @inheritDoc
         */
        override protected function onContentReady(content:*):Boolean 
        {
            if (content is BitmapData)
                _bitmapData = content as BitmapData;
            else if (content is Bitmap)
            {
                // a .png is initialized as a ByteArray and will be provided
                // through the super(). Resource class as a Bitmap
                _bitmapData = (content as Bitmap).bitmapData;
                content = null;
            }
            return _bitmapData != null;
        }
        
        protected var _bitmapData:BitmapData = null;
    }
}