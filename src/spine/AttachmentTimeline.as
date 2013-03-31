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
	public class AttachmentTimeline implements Timeline
	{
		private var _slotIndex : int;
		private var _frames : Vector.<Number>; // time, ...
		private var attachmentNames : Vector.<String>;
		
		public function AttachmentTimeline(frameCount : int)
		{
			_frames = new Vector.<Number>();
			attachmentNames = new  Vector.<String>(frameCount);
		}

		public function getFrameCount () : int {
			return _frames.length;
		}
		
		public function get slotIndex () : int {
			return _slotIndex;
		}
		
		public function set slotIndex (slotIndex : int) : void {
			this._slotIndex = slotIndex;
		}
		
		public function getFrames () : Vector.<Number> {
			return _frames;
		}
		
		public function getAttachmentNames () : Vector.<String> {
			return attachmentNames;
		}
		
		/** Sets the time and value of the specified keyframe. */
		public function setFrame (frameIndex : int, time : Number, attachmentName : String) : void {
			_frames[frameIndex] = time;
			attachmentNames[frameIndex] = attachmentName;
		}
		
		public function apply(skeleton:Skeleton, time:Number, alpha:Number):void
		{
			var frames : Vector.<Number> = this._frames;
			if (time < frames[0]) return; // Time is before first frame.
			
			var frameIndex : int;
			if (time >= frames[frames.length - 1]) // Time is after last frame.
				frameIndex = frames.length - 1;
			else
				frameIndex = Animation.binarySearch(frames, time, 1) - 1;
			
			var attachmentName : String = attachmentNames[frameIndex];
			skeleton.slots[slotIndex].attachment = ( attachmentName == null ) ? null : skeleton.getAttachment(slotIndex, attachmentName);
		}
	}
}