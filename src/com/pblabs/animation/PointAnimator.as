/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.animation
{
   import flash.geom.Point;
   
   /**
    * Animator subclass for animating the flash.geom.Point class.
    */
   public class PointAnimator extends Animator
   {
	   
	   override protected function doEase(start:*, end:*, elapsed:Number, duration:Number):*
	   {
		   var result:Point = new Point();
		   result.x = ease(elapsed, start.x, end.x - start.x, duration);
		   result.y = ease(elapsed, start.y, end.y - start.y, duration);
		   return result;
	   }
	   
      override protected function interpolate(start:*, end:*, time:Number):*
      {
         var result:Point = new Point();
         result.x = super.interpolate(start.x, end.x, time);
         result.y = super.interpolate(start.y, end.y, time);
         return result;
      }
   }
}