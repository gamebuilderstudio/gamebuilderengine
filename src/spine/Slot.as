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

	public class Slot {
		public var color : Color;
		protected var _attachment : Attachment;
		protected var _attachmentTime : Number;
		protected var _bone : Bone;
		protected var _data : SlotData;

		private var _skeleton : Skeleton;
	
		public function Slot (data : SlotData, skeleton : Skeleton , bone : Bone) : void {
			this._data = data;
			this._skeleton = skeleton;
			this._bone = bone;
			color = new Color(1, 1, 1, 1);
		}
	
		public function clone():Slot
		{
			var slot : Slot = new Slot(_data, _skeleton, _bone); 
			slot.color = this.color;
			slot.attachment = this.attachment;
			slot.attachmentTime = this.attachmentTime;
			return slot;
		}
	
		public function get data () : SlotData {
			return _data;
		}
	
		public function get skeleton () : Skeleton{
			return _skeleton;
		}
	
		public function get bone () : Bone{
			return _bone;
		}
	
		/** @return May be null. */
		public function get attachment() : Attachment{
			return _attachment;
		}

		/** Sets the attachment and resets {@link #getAttachmentTime()}.
		 * @param attachment May be null. */
		public function set attachment(attachment : Attachment) : void {
			this._attachment = attachment;
			this._attachmentTime = skeleton.time;
		}
	
		public function set attachmentTime (time : Number) : void{
			_attachmentTime = _skeleton.time - time;
		}
	
		/** Returns the time since the attachment was set. */
		public function get attachmentTime () : Number {
			return _skeleton.time - _attachmentTime;
		}
	
		protected function _setToBindPose (slotIndex : int) : void {
			color = _data.color;
			attachment = (_data.attachmentName == null ? null : skeleton.getAttachment(slotIndex, _data.attachmentName));
		}
	
		public function setToBindPose () : void {
			_setToBindPose(skeleton.slots.indexOf(this));
		}
	
		public function setToBindPoseWithIndex(slotIndex : int) : void {
			_setToBindPose(slotIndex);
		}

		public function toString () : String{
			return _data ? _data.name : null;
		}
	}
}
