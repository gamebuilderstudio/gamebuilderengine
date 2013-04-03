package spine.utils
{
	public final class MathUtils
	{
		public function MathUtils() { }
		
		/**
		 * Returns a random int within a set range.
		 * @param min
		 * @param max
		 * @return
		 */
		public static function randomRange(min:int, max:int):int
		{
			return int(Math.random() * max) + min;
		}
		
		/**
		 * Keep a number between a min and a max.
		 */
		public static function clamp(v:Number, min:Number = 0, max:Number = 1):Number
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
		public static function getRadiansFromDegrees(degrees:Number):Number
		{
			return degrees * Math.PI / 180;
		}
	}
}