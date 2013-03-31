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