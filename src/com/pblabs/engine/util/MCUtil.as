package com.pblabs.engine.util
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
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
	}
}