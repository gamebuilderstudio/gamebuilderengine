/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2012 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package spine
{
	import flash.utils.Dictionary;

	/** Stores mixing times between animations. */
	public class AnimationStateData {
		public const animationToMixTime : Dictionary = new Dictionary();
		public const tempKey : Key = new Key();
		
		public function AnimationStateData() { }

		/** Set the mixing duration between two animations. */
		public function setMix (from : Animation, to : Animation, duration : Number) : void {
			if (from == null) throw new Error("from cannot be null.");
			if (to == null) throw new Error("to cannot be null.");
			var key : Key = new Key();
			key.a1 = from;
			key.a2 = to;
			animationToMixTime[key] = duration;
		}
		
		public function getMix (from : Animation, to : Animation) : Number{
			tempKey.a1 = from;
			tempKey.a2 = to;
			var time : Number = animationToMixTime[tempKey];
			if (isNaN(time)) return 0;
			return time;
		}
	}
}
import spine.Animation;

class Key {
	public var a1 : Animation, a2 : Animation;
	
	public function hashCode () : int {
		return 31 * (31 + Key.GetHashCodeInt(a1.name)) + Key.GetHashCodeInt(a2.name);
	}
	
	public function equals (obj : Object) : Boolean{
		if (this == obj) return true;
		if (obj == null) return false;
		var other : Key = obj as Key;
		if (a1 == null) {
			if (other.a1 != null) return false;
		} else if (!a1 == other.a1) return false;
		if (a2 == null) {
			if (other.a2 != null) return false;
		} else if (!a2 == other.a2) return false;
		return true;
	}
	
	public static function GetHashCodeInt(str:String):int
	{
		var hashString:String = str;
		hashString = hashString.split(/[\s]+/)[0];
		hashString = hashString.substring(1); // get rid of first char
		return int("0x"+hashString);
	}
}