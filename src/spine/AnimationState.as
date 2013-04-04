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
	/** Stores state for an animation and automatically mixes between animations. */
	public class AnimationState 
	{
		/** Returns the time within the current animation. */
		public var currentTime : Number, previousTime : Number;

		private var _data : AnimationStateData;
		private var current : Animation, previous : Animation;
		private var currentLoop : Boolean, previousLoop : Boolean;
		private var mixTime : Number, mixDuration : Number;
		
		public function AnimationState (data : AnimationStateData) : void {
			if (data == null) throw new Error("data cannot be null.");
			this._data = data;
		}
		
		public function update (delta : Number) : void{
			currentTime += delta;
			previousTime += delta;
			mixTime += delta;
		}
		
		public function apply (skeleton : Skeleton) : void {
			if (current == null) return;
			if (previous != null) {
				previous.apply(skeleton, previousTime, previousLoop);
				var alpha : Number = mixTime / mixDuration;
				if (alpha >= 1) {
					alpha = 1;
					previous = null;
				}
				current.mix(skeleton, currentTime, currentLoop, alpha);
			} else
				current.apply(skeleton, currentTime, currentLoop);
		}
		
		/** Set the current animation. The current animation time is set to 0.
		 * @param animation May be null. */
		public function setAnimation (animation : Animation, loop : Boolean) : void {
			previous = null;
			if (animation != null && current != null) {
				mixDuration = _data.getMix(current, animation);
				if (mixDuration > 0) {
					mixTime = 0;
					previous = current;
					previousTime = currentTime;
					previousLoop = currentLoop;
				}
			}
			current = animation;
			currentLoop = loop;
			currentTime = 0;
		}
		
		/** @return May be null. */
		public function getAnimation () : Animation {
			return current;
		}
		
		public function get data () : AnimationStateData {
			return _data;
		}
		
		public function toString () : String {
			return (current != null && current.name != null) ? current.name : super.toString();
		}
	}
}