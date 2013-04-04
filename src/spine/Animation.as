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
	public class Animation {
		private var _name : String;
		private var _timelines : Vector.<Timeline>;
		private var _duration : Number;
		
		public function Animation (timelines : Vector.<Timeline>, duration : Number) : void {
			if (timelines == null) throw new Error("timelines cannot be null.");
			this._timelines = timelines;
			this._duration = duration;
		}
		
		public function get timelines () : Vector.<Timeline>{
			return _timelines;
		}
		
		/** Returns the duration of the animation in seconds. */
		public function get duration () : Number {
			return _duration;
		}
		
		public function set duration (duration : Number) : void {
			this._duration = duration;
		}
		
		/** Poses the skeleton at the specified time for this animation. */
		public function apply (skeleton : Skeleton, time : Number, loop : Boolean) : void {
			if (skeleton == null) throw new Error("skeleton cannot be null.");
			
			if (loop && duration != 0) time %= duration;
			
			var timelines : Vector.<Timeline> = this._timelines;
			var len : int = timelines.length;
			for (var i : int = 0; i < len; i++)
				timelines[i].apply(skeleton, time, 1);
		}
		
		/** Poses the skeleton at the specified time for this animation mixed with the current pose.
		 * @param alpha The amount of this animation that affects the current pose. */
		public function mix (skeleton : Skeleton, time : Number, loop : Boolean, alpha : Number) : void {
			if (skeleton == null) throw new Error("skeleton cannot be null.");
			
			if (loop && duration != 0) time %= duration;
			
			var timelines : Vector.<Timeline> = this._timelines;
			var len : int = timelines.length;
			for (var i : int = 0; i < len; i++)
				timelines[i].apply(skeleton, time, alpha);
		}
		
		/** @return May be null. */
		public function get name () : String{
			return _name;
		}
		
		/** @param name May be null. */
		public function set name (name : String)  : void {
			this._name = name;
		}
		
		public function toString () : String {
			return _name != null ? _name : super.toString();
		}
		
		/** @param target After the first and before the last entry. */
		static public function binarySearch (values : Vector.<Number>, target : Number, step : int) : int {
			var low : int = 0;
			var high : int = values.length / step - 2;
			if (high == 0) return step;
			var current : int = high >>> 1;
			while (true) {
				if (values[(current + 1) * step] <= target)
					low = current + 1;
				else
					high = current;
				if (low == high) return (low + 1) * step;
				current = (low + high) >>> 1;
			}
			return -1;
		}
		
		static private function linearSearch (values : Vector.<Number>, target : Number, step : int) : int {
			var last : int = values.length - step;
			for (var i : int = 0; i <= last; i += step) {
				if (values[i] <= target) continue;
				return i;
			}
			return -1;
		}
	}
}