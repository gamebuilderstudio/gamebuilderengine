/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Animation
{
   import flash.geom.Point;
   
   /**
    * Animator subclass for animating the flash.geom.Point class.
    */
   public class PointAnimator extends Animator
   {
      protected override function _Interpolate(start:*, end:*, time:Number):*
      {
         var result:Point = new Point();
         result.x = super._Interpolate(start.x, end.x, time);
         result.y = super._Interpolate(start.y, end.y, time);
         return result;
      }
   }
}