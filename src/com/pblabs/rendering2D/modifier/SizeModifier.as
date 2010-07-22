/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.rendering2D.modifier
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class SizeModifier extends Modifier
	{
		public var newWidth:int;
		public var newHeight:int;
		public var scaleMode:int=0;
		public var fillColor:uint=0x000000;
		
		//------------------------------------------------------------------
		// public constants
		//------------------------------------------------------------------
		
		public static const SCALE_NONE:int = 0;
		public static const SCALE_STRETCHED:int = 1;
		public static const SCALE_ZOOM:int = 2;
		public static const SCALE_FILL:int = 3;
		public static const SCALE_CENTER:int = 4;
		
		//------------------------------------------------------------------
		// public methods
		//------------------------------------------------------------------		

		public function SizeModifier(newWidth:int, newHeight:int, scaleMode:int=0, fillColor:uint=0x000000)
		{
			this.newWidth = newWidth;
			this.newHeight = newHeight;
			this.scaleMode = scaleMode;
			this.fillColor = fillColor;
			
			super();
		}

		public override function modify(data:BitmapData, index:int = 0, count:int=1):BitmapData
		{
			if (newWidth > 0 && newHeight > 0)
			{
				var bmd:BitmapData;
				
				var destinationWidth:int = data.width;
				var destinationHeight:int = data.height;
				
				if (scaleMode != SCALE_NONE)
				{
					// determine scale aspect ratio for best fit
					var scaleAspectRatio:Number;
					if ((newHeight / newWidth) < (data.height / data.width))
						scaleAspectRatio = newHeight / data.height;
					else
						scaleAspectRatio = newWidth / data.width;
					
					// calculate new width and height of visible destination image 
					destinationWidth = Math.floor(data.width * scaleAspectRatio);
					destinationHeight = Math.floor(data.height * scaleAspectRatio);
				}
				
				var destinationDrawRectangle:Rectangle = new Rectangle((newWidth-destinationWidth)/2, (newHeight-destinationHeight)/2, destinationWidth, destinationHeight);
				var sourceDrawRectangle:Rectangle = new Rectangle(0, 0, data.width, data.height);
				
				// adjust source and destination rectangles depending on scaleMode
				switch (scaleMode)
				{
					case SCALE_STRETCHED:
						// stretch the image to fit the new width and height
						destinationDrawRectangle = new Rectangle(0, 0, newWidth, newHeight);
						break;
					
					case SCALE_FILL:
					case SCALE_CENTER:
						// center image within new width/height rectangle for best fit
						if (newWidth > destinationWidth)
							destinationDrawRectangle = new Rectangle((newWidth-destinationWidth)/2,0,destinationWidth,newHeight);
						else
							destinationDrawRectangle = new Rectangle(0,(newHeight-destinationHeight)/2,newWidth,destinationHeight);
						break;
					
					case SCALE_ZOOM:
						// center zoom into source to exactly fit into new width/height rectangle
						destinationDrawRectangle = new Rectangle(0, 0, newWidth, newHeight);
						var imageRatio:Number = newHeight / newWidth;
						if (newWidth > destinationWidth)
						{
							destinationHeight = (data.width * imageRatio);
							sourceDrawRectangle = new Rectangle(0, (data.height - destinationHeight) / 2, data.width, destinationHeight);
						}
						else
						{
							destinationWidth = (data.height / imageRatio);
							sourceDrawRectangle = new Rectangle((data.width - destinationWidth)/2,0, destinationWidth, data.height);
						}                                
						break;
				}
				
				// draw source BitmapData onto new destination BitmapData
				return drawRect(
					new BitmapData(newWidth, newHeight, !(scaleMode == SCALE_FILL),(scaleMode == SCALE_FILL)?fillColor:0x000000),
					destinationDrawRectangle,data,sourceDrawRectangle);
				
			}			
			return data;			
		}

		//------------------------------------------------------------------
		// private methods
		//------------------------------------------------------------------		
		
		private function drawRect(bmd:BitmapData,drect:Rectangle,bms:BitmapData ,srect:Rectangle):BitmapData
		{
			var sx:Number = (drect.width/srect.width);
			var sy:Number = (drect.height/srect.height);
			var dx:Number = ((srect.x*sx)*-1)+drect.x;
			var dy:Number = ((srect.y*sy)*-1)+drect.y;			
			bmd.draw(new Bitmap(bms),new Matrix(sx,0,0,sy,dx,dy),null,null,drect);
			return bmd;
		}
				
		//------------------------------------------------------------------
		// private variable declarations
		//------------------------------------------------------------------		
		
	}
}