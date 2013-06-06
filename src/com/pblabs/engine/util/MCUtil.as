package com.pblabs.engine.util
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * Movie Clip utility class to handle certain functions that are needed when handling MovieClips.
	 * 
	 * @author lavonw
	 **/
	public final class MCUtil
	{
		public function MCUtil()
		{
		}
		
		public static function getRegistrationPoint(obj : DisplayObject):Point
		{
			if(!obj) throw new Error("The object can't be null to retrieve registration point");
			
			//get the bounds of the object and the location 
			//of the current registration point in relation
			//to the upper left corner of the graphical content
			//note: this is a PSEUDO currentRegX and currentRegY, as the 
			//registration point of a display object is ALWAYS (0, 0):
			var bounds:Rectangle
			if(obj.parent)
				bounds = obj.getBounds(obj.parent);
			else
				bounds = obj.getBounds(obj);
			var currentRegX:Number = obj.x - bounds.left;
			var currentRegY:Number = obj.y - bounds.top;
			return new Point(-currentRegX, -currentRegY);
		}
		
		public static function setRegistrationPoint(obj : DisplayObjectContainer, newX:Number, newY:Number):void
		{
			if(!obj) throw new Error("The object's parent needs to be set to retrieve registration point");
			
			//get the bounds of the object and the location 
			//of the current registration point in relation
			//to the upper left corner of the graphical content
			//note: this is a PSEUDO currentRegX and currentRegY, as the 
			//registration point of a display object is ALWAYS (0, 0):
			var bounds:Rectangle = obj.getBounds(obj);
			var currentRegX:Number = obj.x - bounds.left;
			var currentRegY:Number = obj.y - bounds.top;
			
			var xOffset:Number = newX - currentRegX;
			var yOffset:Number = newY - currentRegY;
			//shift the object to its new location--
			//this will put it back in the same position
			//where it started (that is, VISUALLY anyway):
			obj.x += xOffset;
			obj.y += yOffset;
			
			//shift all the children the same amount,
			//but in the opposite direction
			for(var i:int = 0; i < obj.numChildren; i++) {
				obj.getChildAt(i).x -= xOffset;
				obj.getChildAt(i).y -= yOffset;
			}
		}

		/**
		 * Recursively stops all child clips of a swf MovieClip
		 * If the child does not have a frame at the position, it is skipped.
		 */
		public static function stopMovieClips(parent : MovieClip):void
		{
			if(parent) parent.gotoAndStop(1);
			for (var j:int=0; j<parent.numChildren; j++)
			{
				var mc:MovieClip = parent.getChildAt(j) as MovieClip;
				if(!mc)
					continue;
				
				if (mc.totalFrames >= 1)
					mc.gotoAndStop(1);
				else
					mc.gotoAndStop(mc.totalFrames);
				
				stopMovieClips(mc);
			}
		}
		
		public static function getRealBounds(clip:DisplayObject):Rectangle {
			var bounds:Rectangle = clip.getBounds(clip.parent);
			bounds.x = Math.floor(bounds.x);
			bounds.y = Math.floor(bounds.y);
			bounds.height = Math.ceil(bounds.height);
			bounds.width = Math.ceil(bounds.width);
			
			var realBounds:Rectangle = new Rectangle(0, 0, bounds.width, bounds.height);
			
			// Checking filters in case we need to expand the outer bounds
			if (clip.filters.length > 0)
			{
				// filters
				var j:int = 0;
				//var clipFilters:Array = clipChild.filters.concat();
				var clipFilters:Array = clip.filters;
				var clipFiltersLength:int = clipFilters.length;
				var tmpBData:BitmapData;
				var filterRect:Rectangle;
				
				tmpBData = new BitmapData(realBounds.width, realBounds.height, false);
				filterRect = tmpBData.generateFilterRect(tmpBData.rect, clipFilters[j]);
				tmpBData.dispose();
				
				while (++j < clipFiltersLength)
				{
					tmpBData = new BitmapData(filterRect.width, filterRect.height, true, 0);
					filterRect = tmpBData.generateFilterRect(tmpBData.rect, clipFilters[j]);
					realBounds = realBounds.union(filterRect);
					tmpBData.dispose();
				}
			}
			
			realBounds.offset(bounds.x, bounds.y);
			realBounds.width = Math.max(realBounds.width, 1);
			realBounds.height = Math.max(realBounds.height, 1);
			
			tmpBData = null;
			return realBounds;
		}
		
		public static function getBitmapDataByDisplay(clip:DisplayObject, scaleFactor : Point, clipColorTransform:ColorTransform = null, frameBounds:Rectangle=null):ImageFrameData
		{
			if(!scaleFactor)
				scaleFactor = new Point(1,1);
			var realBounds:Rectangle = getRealBounds(clip);
			
			var bdData : BitmapData = new BitmapData((realBounds.width*scaleFactor.x), (realBounds.height*scaleFactor.y), true, 0);
			var _mat : Matrix = clip.transform.matrix;
			_mat.translate(-realBounds.x, -realBounds.y);
			_mat.scale(scaleFactor.x, scaleFactor.y);
			
			bdData.draw(clip, _mat, clipColorTransform);
			
			var item:ImageFrameData = new ImageFrameData(bdData, realBounds);
			
			bdData = null;
			
			return item;
		}
		
	}
}