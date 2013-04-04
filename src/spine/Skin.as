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

class Key {
	public var slotIndex : int;
	public var name : String;
	protected var _hashCode : int;
	
	public function set(slotName : int, name : String) : void {
		if (name == null) throw new Error("attachmentName cannot be null.");
		this.slotIndex = slotName;
		this.name = name;
		_hashCode = 31 * (31 + Key.GetHashCodeInt(name)) + slotIndex;
	}
	
	public function get hashCode () : int {
		return _hashCode;
	}
	
	public function equals (object : Object) : Boolean {
		if (object == null) return false;
		var other : Key = object as Key;
		if (slotIndex != other.slotIndex) return false;
		if (!name == other.name) return false;
		return true;
	}
	
	public function toString () : String {
		return slotIndex + ":" + name;
	}
	
	public static function GetHashCodeInt(str:String):int
	{
		var hashString:String = str;
		hashString = hashString.split(/[\s]+/)[0];
		hashString = hashString.substring(1); // get rid of first char
		return int("0x"+hashString);
	} 
}