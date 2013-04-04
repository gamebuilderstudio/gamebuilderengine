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
	import spine.utils.MathUtils;

	public class TranslateTimeline extends CurveTimeline
	{
		static public var LAST_FRAME_TIME : int = -3;
		static public var FRAME_X : int = 1;
		static public var FRAME_Y : int = 2;
		
		protected var boneIndex : int;
		protected var frames : Vector.<Number>; // time, value, value, ...
		
		public function TranslateTimeline (keyframeCount : int) : void {
			super(keyframeCount);
			frames = new Vector.<Number>(keyframeCount * 3);
		}
		
		public function setBoneIndex (boneIndex : int) : void {
			this.boneIndex = boneIndex;
		}
		
		public function getBoneIndex() : int{
			return boneIndex;
		}
		
		public function getFrames () : Vector.<Number> {
			return frames;
		}
		
		/** Sets the time and value of the specified keyframe. */
		public function setFrame (keyframeIndex : int, time : Number, x : Number, y : Number) : void {
			keyframeIndex *= 3;
			frames[keyframeIndex] = time;
			frames[keyframeIndex + 1] = x;
			frames[keyframeIndex + 2] = y;
		}
		
		override  public function apply (skeleton : Skeleton, time : Number, alpha : Number) : void {
			var frames : Vector.<Number> = this.frames;
			if (time < frames[0]) return; // Time is before first frame.
			
			var bone : Bone = skeleton.bones[boneIndex];
			
			if (time >= frames[frames.length - 3]) { // Time is after last frame.
				bone.x += (bone.data.x + frames[frames.length - 2] - bone.x) * alpha;
				bone.y += (bone.data.y + frames[frames.length - 1] - bone.y) * alpha;
				return;
			}
			
			// Interpolate between the last frame and the current frame.
			var frameIndex : int = Animation.binarySearch(frames, time, 3);
			var lastFrameX : Number = frames[frameIndex - 2];
			var lastFrameY : Number = frames[frameIndex - 1];
			var frameTime : Number = frames[frameIndex];
			var percent : Number = MathUtils.clamp(1 - (time - frameTime) / (frames[frameIndex + LAST_FRAME_TIME] - frameTime), 0, 1);
			percent = getCurvePercent(frameIndex / 3 - 1, percent);
			
			bone.x += (bone.data.x + lastFrameX + (frames[frameIndex + FRAME_X] - lastFrameX) * percent - bone.x) * alpha;
			bone.y += (bone.data.y + lastFrameY + (frames[frameIndex + FRAME_Y] - lastFrameY) * percent - bone.y) * alpha;
		}
	}
}