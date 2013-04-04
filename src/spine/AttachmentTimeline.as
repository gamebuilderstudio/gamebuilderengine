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