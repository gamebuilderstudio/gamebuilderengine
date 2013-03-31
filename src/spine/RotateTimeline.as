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