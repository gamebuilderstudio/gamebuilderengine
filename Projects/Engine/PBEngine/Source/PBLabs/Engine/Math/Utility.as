package PBLabs.Engine.Math
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