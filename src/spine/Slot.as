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
