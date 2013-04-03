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
	import spine.utils.Color;
	import spine.utils.ColorUtil;
	import spine.utils.MathUtils;
	
	public class ColorTimeline extends CurveTimeline
	{
		static private var LAST_FRAME_TIME : int = -5;
		static private var FRAME_R : int = 1;
		static private var FRAME_G : int = 2;
		static private var FRAME_B : int = 3;
		static private var FRAME_A : int = 4;
		
		private var slotIndex : int;
		private var frames : Vector.<Number>; // time, r, g, b, a, ...
		
		public function ColorTimeline (keyframeCount : int) : void{
			super(keyframeCount);
			frames = new Vector.<Number>(keyframeCount * 5);
		}
		
		public function setSlotIndex (slotIndex : int) : void {
			this.slotIndex = slotIndex;
		}
		
		public function getSlotIndex () : int{
			return slotIndex;
		}
		
		public function getFrames () : Vector.<Number>{
			return frames;
		}
		
		/** Sets the time and value of the specified keyframe. */
		public function setFrame (keyframeIndex : int, time : Number, r : Number, g : Number, b : Number, a : Number) : void {
			keyframeIndex *= 5;
			frames[keyframeIndex] = time;
			frames[keyframeIndex + 1] = r;
			frames[keyframeIndex + 2] = g;
			frames[keyframeIndex + 3] = b;
			frames[keyframeIndex + 4] = a;
		}
		
		override public function apply ( skeleton : Skeleton, time : Number, alpha : Number) : void {
			var frames : Vector.<Number> = this.frames;
			if (time < frames[0]) return; // Time is before first frame.
			
			var color : Color = skeleton.slots[slotIndex].color;
			
			if (time >= frames[frames.length - 5]) { // Time is after last frame.
				var i : int = frames.length - 1;
				var r : Number = frames[i - 3];
				var g : Number = frames[i - 2];
				var b : Number = frames[i - 1];
				var a : Number = frames[i];
				color.set(r, g, b, a);
				return;
			}
			
			// Interpolate between the last frame and the current frame.
			var frameIndex : int = Animation.binarySearch(frames, time, 5);
			var lastFrameR : Number = frames[frameIndex - 4];
			var lastFrameG : Number = frames[frameIndex - 3];
			var lastFrameB : Number = frames[frameIndex - 2];
			var lastFrameA : Number = frames[frameIndex - 1];
			var frameTime : Number = frames[frameIndex];
			var percent : Number = MathUtils.clamp(1 - (time - frameTime) / (frames[frameIndex + LAST_FRAME_TIME] - frameTime), 0, 1);
			percent = getCurvePercent(frameIndex / 5 - 1, percent);
			
			r = lastFrameR + (frames[frameIndex + FRAME_R] - lastFrameR) * percent;
			g = lastFrameG + (frames[frameIndex + FRAME_G] - lastFrameG) * percent;
			b = lastFrameB + (frames[frameIndex + FRAME_B] - lastFrameB) * percent;
			a = lastFrameA + (frames[frameIndex + FRAME_A] - lastFrameA) * percent;
			
			if (alpha < 1)
				color.add((r - color.r) * alpha, (g - color.g) * alpha, (b - color.b) * alpha, (a - color.a) * alpha);
			else
				color.set(r, g, b, a);
		}
	}
}