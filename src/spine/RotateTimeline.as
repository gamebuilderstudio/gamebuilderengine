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
	import com.pblabs.engine.PBUtil;
	
	import spine.utils.MathUtils;

	public class RotateTimeline extends CurveTimeline
	{
		static private var LAST_FRAME_TIME : int = -2;
		static private var FRAME_VALUE : int = 1;
		
		private var boneIndex : int;
		private var frames : Vector.<Number>; // time, value, ...
		
		public function RotateTimeline(keyframeCount:int)
		{
			super(keyframeCount);
			frames = new Vector.<Number>(keyframeCount * 2);
		}
		
		public function setBoneIndex (boneIndex : int) : void {
			this.boneIndex = boneIndex;
		}
		
		public function getBoneIndex () : int {
			return boneIndex;
		}
		
		public function getFrames () : Vector.<Number> {
			return frames;
		}
		
		/** Sets the time and value of the specified keyframe. */
		public function setFrame (keyframeIndex : int, time : Number, value : Number) : void {
			keyframeIndex *= 2;
			frames[keyframeIndex] = time;
			frames[keyframeIndex + 1] = value;
		}
		
		override public function apply (skeleton : Skeleton, time : Number, alpha : Number) : void {
			var frames : Vector.<Number> = this.frames;
			if (time < frames[0]) return; // Time is before first frame.
			
			 var bone : Bone = skeleton.bones[boneIndex];
			
			 var amount : Number;
			 if (time >= frames[frames.length - 2]) { // Time is after last frame.
				 amount = bone.data.rotation + frames[frames.length - 1] - bone.rotation;
				 while (amount > 180)
					 amount -= 360;
				 while (amount < -180)
					 amount += 360;
				 bone.rotation += amount * alpha;
				 return;
			 }
			 
			 // Interpolate between the last frame and the current frame.
			 var frameIndex : int = Animation.binarySearch(frames, time, 2);
			 var lastFrameValue : Number = frames[frameIndex - 1];
			 var frameTime : Number = frames[frameIndex];
			 var percent : Number = MathUtils.clamp(1 - (time - frameTime) / (frames[frameIndex + LAST_FRAME_TIME] - frameTime), 0, 1);
			 percent = getCurvePercent(frameIndex / 2 - 1, percent);
			 
			 amount = frames[frameIndex + FRAME_VALUE] - lastFrameValue;
			 while (amount > 180)
				 amount -= 360;
			 while (amount < -180)
				 amount += 360;
			 amount = bone.data.rotation + (lastFrameValue + amount * percent) - bone.rotation;
			 while (amount > 180)
				 amount -= 360;
			 while (amount < -180)
				 amount += 360;
			 bone.rotation += amount * alpha;
		}
	}
}