/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.math
{
   /**
    * Contains math related utility methods.
    */
   public class Utility
   {
      /**
       * Converts an angle in radians to an angle in degrees.
       * 
       * @param radians The angle to convert.
       * 
       * @return The converted value.
       */
      public static function GetDegreesFromRadians(radians:Number):Number
      {
         return radians * 180 / Math.PI;
      }
      
      /**
       * Keep a number between a min and a max.
       */
      public static function Clamp(v:Number, min:Number = 0, max:Number = 1):Number
      {
         if(v < min) return min;
         if(v > max) return max;
         return v;
      }
      
      /**
       * Converts an angle in degrees to an angle in radians.
       * 
       * @param degrees The angle to convert.
       * 
       * @return The converted value.
       */
      public static function GetRadiansFromDegrees(degrees:Number):Number
      {
         return degrees * Math.PI / 180;
      }
      
      /**
       * Take a radian measure and make sure it is between 0..2pi.
       */
      public static function UnwrapRadian(r:Number):Number
      {
         while(r > Math.PI * 2)
            r -= Math.PI * 2;
         while(r < 0)
            r += Math.PI * 2;
            
         return r;
      }
     
      /**
       * Return the shortest distance to get from from to to, in radians.
       */
      public static function GetRadianShortDelta(from:Number, to:Number):Number
      {
         // Unwrap both from and to.
         from = UnwrapRadian(from);
         to = UnwrapRadian(to);
         
         // Calc delta.
         var delta:Number = to - from;
         
         // Make sure delta is shortest path around circle.
         if(delta > Math.PI)
            delta -= Math.PI * 2;            
         if(delta < -Math.PI)
            delta += Math.PI * 2;            
            
         // Done
         return delta;
      }
      
      /**
       * Get number of bits required to encode values from 0..max.
       *
       * @param max The maximum value to be able to be encoded.
       * @return Bitcount required to encode max value.
       */
      public static function GetBitCountForRange(max:int):int
      {
         // TODO: Make this use bits and be fast.
         return Math.ceil(Math.log(max) / Math.log(2.0));
      }
   }
}