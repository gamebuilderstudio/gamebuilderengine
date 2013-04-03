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
	import flash.utils.Dictionary;
	
	/** Stores attachments by slot index and attachment name. */
	public class Skin {
		public var attachments : Dictionary = new Dictionary();
		protected var _name : String;
	
		public function Skin (name : String) : void {
			if (name == null) throw new Error("name cannot be null.");
			this._name = name;
		}
	
		public function addAttachment (slotIndex : int, name : String, attachment : Attachment) : void {
			if (attachment == null) throw new Error("attachment cannot be null.");
			var key : Key = new Key();
			key.set(slotIndex, name);
			attachments[key] = attachment;
		}
	
		/** @return May be null. */
		public function getAttachment (slotIndex : int, name : String) : Attachment {
			for(var key : * in attachments)
			{
				var keyData : Attachment  = attachments[key];
				if(key.name == name && key.slotIndex == slotIndex)
					return keyData;
			}
			return null;
		}
	
		public function findNamesForSlot (slotIndex : int, names :  Vector.<String>) : void {
			if (names == null) throw new Error("names cannot be null.");
			for(var key : * in attachments)
			{
				//var keyData : Attachment  = attachments[key];
				if(key.slotIndex == slotIndex)
					names.push(key.name);
			}
		}
	
		public function findAttachmentsForSlot (slotIndex : int, attachments : Vector.<Attachment>) : void {
			if (attachments == null) throw new Error("attachments cannot be null.");

			for(var key : * in attachments)
			{
				var keyData : Attachment  = attachments[key];
				if (key.slotIndex == slotIndex) 
					attachments.push(keyData);
			}
		}
	
		public function clear () : void {
			for(var key : * in attachments)
			{
				delete attachments[key];
			}
		}
		
		/** Attach all attachments from this skin if the corresponding attachment from the old skin is currently attached. */
		public function attachAll (skeleton : Skeleton, oldSkin : Skin) : void {
			for (var key : * in oldSkin.attachments) {
				var keyData : Key = key as Key;
				var slotIndex : int = keyData.slotIndex;
				var slot : Slot = skeleton.slots[slotIndex];
				if (slot.attachment == oldSkin.attachments[key]) {
					var attachment : Attachment = getAttachment(slotIndex, keyData.name);
					if (attachment != null) slot.attachment = attachment;
				}
			}
		}
	
		public function get name () : String {
			return _name;
		}
	
		public function toString () : String{
			return _name;
		}
	
	}
}