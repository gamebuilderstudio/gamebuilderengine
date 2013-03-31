/*******************************************************************************
 * Copyright (c) 2013, Esoteric Software
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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