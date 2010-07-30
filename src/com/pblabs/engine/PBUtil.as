/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine
{
    import com.pblabs.engine.debug.Logger;
    
    import flash.display.DisplayObject;
    import flash.geom.Matrix;

    /**
     * Contains math related utility methods.
     */
    public class PBUtil
    {
		public static const FLIP_HORIZONTAL:String = "flipHorizontal";
		public static const FLIP_VERTICAL:String = "flipVertical";
		
        /**
         * Two times PI. 
         */
        public static const TWO_PI:Number = 2.0 * Math.PI;
        
        /**
         * Converts an angle in radians to an angle in degrees.
         * 
         * @param radians The angle to convert.
         * 
         * @return The converted value.
         */
        public static function getDegreesFromRadians(radians:Number):Number
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
        public static function getRadiansFromDegrees(degrees:Number):Number
        {
            return degrees * Math.PI / 180;
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
		 * Clones an array.
		 * @param array Array to clone.
		 * @return a cloned array.
		 */
		public static function cloneArray(array:Array):Array
		{
			var newArray:Array = [];

			for each (var item:* in array)
				newArray.push(item);
			
			return newArray;
		}
		
		/**
		 * Take a radian measure and make sure it is between -pi..pi. 
		 */
		public static function unwrapRadian(r:Number):Number 
		{ 
			r = r % TWO_PI;
			if (r > Math.PI) 
				r -= TWO_PI; 
			if (r < -Math.PI) 
				r += TWO_PI; 
			return r; 
		} 
        
        /**
         * Take a degree measure and make sure it is between -180..180.
         */
        public static function unwrapDegrees(r:Number):Number
        {
            r = r % 360;
            if (r > 180)
                r -= 360;
            if (r < -180)
                r += 360;
            return r;
        }

        /**
         * Return the shortest distance to get from from to to, in radians.
         */
        public static function getRadianShortDelta(from:Number, to:Number):Number
        {
            // Unwrap both from and to.
            from = unwrapRadian(from);
            to = unwrapRadian(to);
            
            // Calc delta.
            var delta:Number = to - from;
            
            // Make sure delta is shortest path around circle.
            if(delta > Math.PI)
                delta -= TWO_PI;            
            if(delta < -Math.PI)
                delta += TWO_PI;            
            
            // Done
            return delta;
        }
        
        /**
         * Return the shortest distance to get from from to to, in degrees.
         */
        public static function getDegreesShortDelta(from:Number, to:Number):Number
        {
            // Unwrap both from and to.
            from = unwrapDegrees(from);
            to = unwrapDegrees(to);
            
            // Calc delta.
            var delta:Number = to - from;
            
            // Make sure delta is shortest path around circle.
            if(delta > 180)
                delta -= 360;            
            if(delta < -180)
                delta += 360;            
            
            // Done
            return delta;
        }

        /**
         * Get number of bits required to encode values from 0..max.
         *
         * @param max The maximum value to be able to be encoded.
         * @return Bitcount required to encode max value.
         */
        public static function getBitCountForRange(max:int):int
        {
			var count:int = 0;

			// Unfortunately this is a bug with this method... and requires this special
			// case (same issue with the old method log calculation)
			if (max == 1) return 1;

			max--;
			while (max >> count > 0) count++;
			return count;
        }
        
        /**
         * Pick an integer in a range, with a bias factor (from -1 to 1) to skew towards
         * low or high end of range.
         *  
         * @param min Minimum value to choose from, inclusive.
         * @param max Maximum value to choose from, inclusive.
         * @param bias -1 skews totally towards min, 1 totally towards max.
         * @return A random integer between min/max with appropriate bias.
         * 
         */
        public static function pickWithBias(min:int, max:int, bias:Number = 0):int
        {
            return clamp((((Math.random() + bias) * (max - min)) + min), min, max);
        }
        
        /**
         * Assigns parameters from source to destination by name.
         * 
         * <p>This allows duck typing - you can accept a generic object
         * (giving you nice {foo:bar} syntax) and cast to a typed object for
         * easier internal processing and validation.</p>
         * 
         * @param source Object to read fields from.
         * @param destination Object to assign fields to.
         * @param abortOnMismatch If true, throw an error if a field in source is absent in destination.
         * 
         */
        public static function duckAssign(source:Object, destination:Object, abortOnMismatch:Boolean = false):void
        {
            for(var field:String in source)
            {
                try
                {
                    // Try to assign.
                    destination[field] = source[field];
                }
                catch(e:Error)
                {
                    // Abort or continue, depending on user settings.
                    if(!abortOnMismatch)
                        continue;
                    throw new Error("Field '" + field + "' in source was not present in destination.");
                }
            }
        }
		
        /**
         * Calculate length of a vector. 
         */
        public static function xyLength(x:Number, y:Number):Number
        {
            return Math.sqrt((x*x)+(y*y));
        }
        
		/**
		 * Replaces instances of less then, greater then, ampersand, single and double quotes.
		 * @param str String to escape.
		 * @return A string that can be used in an htmlText property.
		 */		
		public static function escapeHTMLText(str:String):String
		{
			var chars:Array = 
			[
				{char:"&", repl:"|amp|"},
				{char:"<", repl:"&lt;"},
				{char:">", repl:"&gt;"},
				{char:"\'", repl:"&apos;"},
				{char:"\"", repl:"&quot;"},
				{char:"|amp|", repl:"&amp;"}
			];
			
			for(var i:int=0; i < chars.length; i++)
			{
				while(str.indexOf(chars[i].char) != -1)
				{
					str = str.replace(chars[i].char, chars[i].repl);
				}
			}
			
			return str;
		}
		
		/**
		 * Converts a String to a Boolean. This method is case insensitive, and will convert 
		 * "true", "t" and "1" to true. It converts "false", "f" and "0" to false.
		 * @param str String to covert into a boolean. 
		 * @return true or false
		 */		
		public static function stringToBoolean(str:String):Boolean
		{
			switch(str.substring(1, 0).toUpperCase())
			{
				case "F":
				case "0":
					return false;
					break;
				case "T":
				case "1":
					return true;
					break;
			}
			
			return false;
		}
        
		/**
		 * Capitalize the first letter of a string 
		 * @param str String to capitalize the first leter of
		 * @return String with the first letter capitalized.
		 */		
		public static function capitalize(str:String):String
		{
			return str.substring(1, 0).toUpperCase() + str.substring(1);
		}
		
		/**
		 * Removes all instances of the specified character from 
		 * the beginning and end of the specified string.
		 */
		public static function trim(str:String, char:String):String {
			return trimBack(trimFront(str, char), char);
		}
		
		/**
		 * Recursively removes all characters that match the char parameter, 
		 * starting from the front of the string and working toward the end, 
		 * until the first character in the string does not match char and returns 
		 * the updated string.
		 */		
		public static function trimFront(str:String, char:String):String
		{
			char = stringToCharacter(char);
			if (str.charAt(0) == char) {
				str = trimFront(str.substring(1), char);
			}
			return str;
		}
		
		/**
		 * Recursively removes all characters that match the char parameter, 
		 * starting from the end of the string and working backward, 
		 * until the last character in the string does not match char and returns 
		 * the updated string.
		 */		
		public static function trimBack(str:String, char:String):String
		{
			char = stringToCharacter(char);
			if (str.charAt(str.length - 1) == char) {
				str = trimBack(str.substring(0, str.length - 1), char);
			}
			return str;
		}
		
		/**
		 * Returns the first character of the string passed to it. 
		 */		
		public static function stringToCharacter(str:String):String 
		{
			if (str.length == 1) {
				return str;
			}
			return str.slice(0, 1);
		}
		
        /**
         * Determine the file extension of a file. 
         * @param file A path to a file.
         * @return The file extension.
         * 
         */
        public static function getFileExtension(file:String):String
        {
            var extensionIndex:Number = file.lastIndexOf(".");
           if (extensionIndex == -1) {
                //No extension
                return "";
            } else {
                return file.substr(extensionIndex + 1,file.length);
            }
        }
        
		/**
		 * Method for flipping a DisplayObject 
		 * @param obj DisplayObject to flip
		 * @param orientation Which orientation to use: PBUtil.FLIP_HORIZONTAL or PBUtil.FLIP_VERTICAL
		 * 
		 */		
		public static function flipDisplayObject(obj:DisplayObject, orientation:String):void
		{
			var m:Matrix = obj.transform.matrix;
			 
			switch (orientation) 
			{
				case FLIP_HORIZONTAL:
					m.a = -1 * m.a;
					m.tx = obj.width + obj.x;
					break;
				case FLIP_VERTICAL:
					m.d = -1 * m.d;
					m.ty = obj.height + obj.y;
					break;
			}
			
			obj.transform.matrix = m;
		}
		
        /**
         * Log an object to the console. Based on http://dev.base86.com/solo/47/actionscript_3_equivalent_of_phps_printr.html 
         * @param thisObject Object to display for logging.
         * @param obj Object to dump.
         */
        public static function dumpObjectToLogger(thisObject:*, obj:*, level:int = 0, output:String = ""):String
        {
            var tabs:String = "";
            for(var i:int = 0; i < level; i++) tabs += "\t";
            
            for(var child:* in obj) {
                output += tabs +"["+ child +"] => "+ obj[child];
                
                var childOutput:String = dumpObjectToLogger(thisObject, obj[child], level+1);
                if(childOutput != '') output += ' {\n'+ childOutput + tabs +'}';
                
                output += "\n";
            }
            
            if(level == 0)
            {
                Logger.print(thisObject, output);
                return "";
            }
            
            return output;
        }
    }
}
