/*******************************************************************************
 * Copyright 2011 See AUTHORS file.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ******************************************************************************/

package spine.utils
{
	
	/** A color class, holding the r, g, b and alpha component as floats in the range [0,1]. All methods perform clamping on the
	 * internal values after execution.
	 * 
	 * @author mzechner */
	public class Color {
		public static var CLEAR : Color = new Color(0, 0, 0, 0);
		public static var WHITE : Color = new Color(1, 1, 1, 1);
		public static var BLACK : Color = new Color(0, 0, 0, 1);
		public static var RED : Color = new Color(1, 0, 0, 1);
		public static var GREEN : Color = new Color(0, 1, 0, 1);
		public static var BLUE : Color = new Color(0, 0, 1, 1);
		public static var LIGHT_GRAY : Color = new Color(0.75, 0.75, 0.75, 1);
		public static var GRAY : Color = new Color(0.5, 0.5, 0.5, 1);
		public static var DARK_GRAY : Color = new Color(0.25, 0.25, 0.25, 1);
		public static var PINK : Color = new Color(1, 0.68, 0.68, 1);
		public static var ORANGE : Color = new Color(1, 0.78, 0, 1);
		public static var YELLOW : Color = new Color(1, 1, 0, 1);
		public static var MAGENTA : Color = new Color(1, 0, 1, 1);
		public static var CYAN : Color = new Color(0, 1, 1, 1);
		
		/** the red, green, blue and alpha components **/
		public var r : Number, g : Number, b : Number, a : Number;
		
		/** Constructor, sets the components of the color
		 * 
		 * @param r the red component
		 * @param g the green component
		 * @param b the blue component
		 * @param a the alpha component */
		public function Color (r : Number = 0, g : Number = 0, b : Number = 0, a : Number = 0) : void{
			this.r = r;
			this.g = g;
			this.b = b;
			this.a = a;
			clamp();
		}
		
		/** Constructs a new color using the given color
		 * 
		 * @param color the color */
		public function clone (color : Color) : Color{
			return new Color(r, g, b, a)
		}
		
		/** Sets this color to the given color.
		 * 
		 * @param color the Color */
		public function setToColor(color : Color) : Color {
			this.r = color.r;
			this.g = color.g;
			this.b = color.b;
			this.a = color.a;
			return this;
		}
		
		/** Sets this color to the given color.
		 * 
		 * @param color the Color */
		public function set(r : Number = 0, g : Number = 0, b : Number = 0, a : Number = 0) : void {
			this.r = r;
			this.g = g;
			this.b = b;
			this.a = a;
		}

		/** Multiplies the this color and the given color
		 * 
		 * @param color the color
		 * @return this color. */
		public function multiply (color : Color) : Color{
			this.r *= color.r;
			this.g *= color.g;
			this.b *= color.b;
			this.a *= color.a;
			return clamp();
		}
		
		/** Multiplies all components of this Color with the given value.
		 * 
		 * @param value the value
		 * @return this color */
		public function multiplyByColor (value : Number) : Color {
			this.r *= value;
			this.g *= value;
			this.b *= value;
			this.a *= value;
			return clamp();
		}
		
		/** Adds the given color to this color.
		 * 
		 * @param color the color
		 * @return this color */
		public function add (r : Number = 0, g : Number = 0, b : Number = 0, a : Number = 0) : Color {
			this.r += r;
			this.g += g;
			this.b += b;
			this.a += a;
			return clamp();
		}
		
		/** Adds the given color to this color.
		 * 
		 * @param color the color
		 * @return this color */
		public function addColor (color : Color) : Color {
			this.r += color.r;
			this.g += color.g;
			this.b += color.b;
			this.a += color.a;
			return clamp();
		}

		/** Subtracts the given color from this color
		 * 
		 * @param color the color
		 * @return this color */
		public function sub (color : Color) : Color {
			this.r -= color.r;
			this.g -= color.g;
			this.b -= color.b;
			this.a -= color.a;
			return clamp();
		}
		
		/** @return this Color for chaining */
		public function clamp () : Color {
			if (r < 0)
				r = 0;
			else if (r > 1) r = 1;
			
			if (g < 0)
				g = 0;
			else if (g > 1) g = 1;
			
			if (b < 0)
				b = 0;
			else if (b > 1) b = 1;
			
			if (a < 0)
				a = 0;
			else if (a > 1) a = 1;
			return this;
		}
		
		/** Returns the color encoded as hex string with the format RRGGBBAA. */
		public function toString () : String {
			/*String value = Integer.toHexString(((int)(255 * r) << 24) | ((int)(255 * g) << 16) | ((int)(255 * b) << 8)
				| ((int)(255 * a)));
			while (value.length() < 8)
				value = "0" + value;
			return value;*/
			return null;
		}
		
		public static function testFunction():void
		{
			
		}
		
		/** Gets a color object from a hex string
		 * 
		 * @param hex The hex string
		 **/
		public static function valueOfHex (hex : String) : Color {
			if(!hex) return null;
			var r : int = int(hex.substring(0, 2));
			var g : int = int(hex.substring(2, 4));
			var b : int = int(hex.substring(4, 6));
			var a : int = hex.length != 8 ? 255 : int(hex.substring(6, 8));
			return new Color(r / 255, g / 255, b / 255, a / 255);
		}
		
		/** Packs the color components into a 32-bit integer with the format ABGR. Note that no range checking is performed for higher
		 * performance.
		 * @param r the red component, 0 - 255
		 * @param g the green component, 0 - 255
		 * @param b the blue component, 0 - 255
		 * @param a the alpha component, 0 - 255
		 * @return the packed color as a 32-bit int */
		public static function toIntBits (r : int, g : int, b : int, a : int) : int {
			return (a << 24) | (b << 16) | (g << 8) | r;
		}
		
		public static function alpha (alpha : Number) : int {
			return int(alpha * 255.0);
		}
		
		/*
		public static function luminanceAlpha (luminance : Number, alpha : Number) : int {
			return int((luminance * 255.0) << 8)) || int(alpha * 255);
		}
		public static int rgb565 (float r, float g, float b) {
			return ((int)(r * 31) << 11) | ((int)(g * 63) << 5) | (int)(b * 31);
		}
		
		public static int rgba4444 (float r, float g, float b, float a) {
			return ((int)(r * 15) << 12) | ((int)(g * 15) << 8) | ((int)(b * 15) << 4) | (int)(a * 15);
		}
		
		public static int rgb888 (float r, float g, float b) {
			return ((int)(r * 255) << 16) | ((int)(g * 255) << 8) | (int)(b * 255);
		}
		
		public static int rgba8888 (float r, float g, float b, float a) {
			return ((int)(r * 255) << 24) | ((int)(g * 255) << 16) | ((int)(b * 255) << 8) | (int)(a * 255);
		}
		
		public static int rgb565 (Color color) {
			return ((int)(color.r * 31) << 11) | ((int)(color.g * 63) << 5) | (int)(color.b * 31);
		}
		
		public static int rgba4444 (Color color) {
			return ((int)(color.r * 15) << 12) | ((int)(color.g * 15) << 8) | ((int)(color.b * 15) << 4) | (int)(color.a * 15);
		}
		
		public static int rgb888 (Color color) {
			return ((int)(color.r * 255) << 16) | ((int)(color.g * 255) << 8) | (int)(color.b * 255);
		}
		
		public static int rgba8888 (Color color) {
			return ((int)(color.r * 255) << 24) | ((int)(color.g * 255) << 16) | ((int)(color.b * 255) << 8) | (int)(color.a * 255);
		}
		*/
		/** Sets the Color components using the specified integer value in the format RGB565. This is inverse to the rgb565(r, g, b)
		 * method.
		 * 
		 * @param color The Color to be modified.
		 * @param value An integer color value in RGB565 format. 
		 **/
		/*public static void rgb565ToColor (Color color, int value) {
			color.r = ((value & 0x0000F800) >>> 11) / 31f;
			color.g = ((value & 0x000007E0) >>> 5) / 63f;
			color.b = ((value & 0x0000001F) >>> 0) / 31f;
		}*/
		
		/** Sets the Color components using the specified integer value in the format RGBA4444. This is inverse to the rgba4444(r, g, b,
		 * a) method.
		 * 
		 * @param color The Color to be modified.
		 * @param value An integer color value in RGBA4444 format. 
		 **/
		/*		
		public static void rgba4444ToColor (Color color, int value) {
			color.r = ((value & 0x0000f000) >>> 12) / 15f;
			color.g = ((value & 0x00000f00) >>> 8) / 15f;
			color.b = ((value & 0x000000f0) >>> 4) / 15f;
			color.a = ((value & 0x0000000f)) / 15f;
		}*/
		
		/** Sets the Color components using the specified integer value in the format RGB888. This is inverse to the rgb888(r, g, b)
		 * method.
		 * 
		 * @param color The Color to be modified.
		 * @param value An integer color value in RGB888 format. */
		/*public static void rgb888ToColor (Color color, int value) {
			color.r = ((value & 0x00ff0000) >>> 16) / 255f;
			color.g = ((value & 0x0000ff00) >>> 8) / 255f;
			color.b = ((value & 0x000000ff)) / 255f;
		}*/
		
		/** Sets the Color components using the specified integer value in the format RGBA8888. This is inverse to the rgb8888(r, g, b,
		 * a) method.
		 * 
		 * @param color The Color to be modified.
		 * @param value An integer color value in RGBA8888 format. */
		/*public static void rgba8888ToColor (Color color, int value) {
			color.r = ((value & 0xff000000) >>> 24) / 255f;
			color.g = ((value & 0x00ff0000) >>> 16) / 255f;
			color.b = ((value & 0x0000ff00) >>> 8) / 255f;
			color.a = ((value & 0x000000ff)) / 255f;
		}*/
	}
}