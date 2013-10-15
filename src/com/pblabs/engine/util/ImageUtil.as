package com.pblabs.engine.util
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.geom.Matrix;
	import flash.geom.Point;

	/**
	 * Image utility class to handle certain functions that are needed when handling Bitmaps.
	 * 
	 * @author lavonw
	 **/
	public final class ImageUtil
	{
		public function ImageUtil()
		{
		}
		
		/**
		 * Resize a bitmap to fit proportionately inside a proposed width and height
		 * @param image : Bitmap - the bitmap that needs to be resized. This bitmap will be changed directly.
		 * @param width : Number - the width that you want to fit the bitmap within
		 * @param height : Number - the height that you want to fit the bitmap within
		 */
		//public static function resizeBitmap(image : Bitmap, destW : Number, destH : Number):void
		public static function resizeBitmap(bitmap : Bitmap, Width:Number=80, Height:Number=80):Bitmap{
			if(Width <= 0 || Height <= 0) return bitmap;
			
			if(Width/Height == Infinity){
				//if you set the slide show to 0 width and
				//0 height then instead of crashing the swf it will just return the
				//picture as it is
				return bitmap;
			}
			var ratio:Number =  bitmap.width/bitmap.height;
			var assetHeight:Number = Height;//now instead of setting the picture
			//size we calculate what the size should be with two new variables.
			var assetWidth:Number =  assetHeight*ratio;
			if(assetWidth>Width){
				assetWidth =  Width;
				assetHeight = assetWidth/ratio;
			}
			var scaleBy : Point = new Point((assetWidth/bitmap.width),  (assetHeight/bitmap.height));
			
			var originalBitmapData:BitmapData = bitmap.bitmapData;
			var newWidth:Number = originalBitmapData.width * scaleBy.x;
			var newHeight:Number = originalBitmapData.height * scaleBy.y;
			var scaledBitmapData:BitmapData=new BitmapData(newWidth, newHeight,true,0x000000);
			var scaleMatrix:Matrix=new Matrix();
			scaleMatrix.scale(scaleBy.x,scaleBy.y);
			scaledBitmapData.draw(originalBitmapData,scaleMatrix);
			
			bitmap.bitmapData = scaledBitmapData;
			bitmap.smoothing = true;
			bitmap.pixelSnapping = PixelSnapping.NEVER;
			return bitmap;
		}
	}
}