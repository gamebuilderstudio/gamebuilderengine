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

	public class ScaleTimeline extends TranslateTimeline
	{
		public function ScaleTimeline (keyframeCount : int) : void {
			super(keyframeCount);
		}
		
		override  public function apply (skeleton : Skeleton, time : Number, alpha : Number) : void {
			var frames : Vector.<Number> = this.frames;
			if (time < frames[0]) return; // Time is before first frame.
			
			var bone : Bone = skeleton.bones[boneIndex];
			if (time >= frames[frames.length - 3]) { // Time is after last frame.
				bone.scaleX = bone.data.scaleX - 1 + frames[frames.length - 2];
				bone.scaleY = bone.data.scaleY - 1 + frames[frames.length - 1];
				return;
			}
			
			// Interpolate between the last frame and the current frame.
			var frameIndex : int = Animation.binarySearch(frames, time, 3);
			var lastFrameX : Number = frames[frameIndex - 2];
			var lastFrameY : Number = frames[frameIndex - 1];
			var frameTime : Number = frames[frameIndex];
			var percent  : Number = MathUtils.clamp(1 - (time - frameTime) / (frames[frameIndex + LAST_FRAME_TIME] - frameTime), 0, 1);
			percent = getCurvePercent(frameIndex / 3 - 1, percent);
			
			bone.scaleX += (bone.data.scaleX - 1 + lastFrameX + (frames[frameIndex + FRAME_X] - lastFrameX) * percent - bone.scaleX) * alpha;
			bone.scaleY += (bone.data.scaleY - 1 + lastFrameY + (frames[frameIndex + FRAME_Y] - lastFrameY) * percent - bone.scaleY) * alpha;
		}
	}
}