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
	import spine.BoneData;
	import spine.SlotData;
	import spine.Skin;
	
	public class SkeletonData 
	{
		public var name : String;
		
		protected var _skins : Vector.<Skin> = new Vector.<Skin>(); // Bind pose draw order.
		protected var _slots : Vector.<SlotData> = new Vector.<SlotData>(); // Bind pose draw order.
		protected var _bones : Vector.<BoneData> = new Vector.<BoneData>(); // Ordered parents first.
		protected var _defaultSkin : Skin;
	
		public function SkeletonData () : void {
		}
	
		public function clear() : void{
			_bones.splice(0, _bones.length);
			_slots.splice(0, _bones.length);
			_skins.splice(0, _bones.length);
			_defaultSkin = null;
		}
	
		// --- Bones.
	
		public function addBone (bone : BoneData) : void {
			if (bone == null) throw new Error("bone cannot be null.");
			bones.push(bone);
		}
	
		public function get bones () : Vector.<BoneData> {
			return _bones;
		}
	
		/** @return May be null. */
		public function findBone (boneName : String) : BoneData{
			if (boneName == null) throw new Error("boneName cannot be null.");
			var len : int = _bones.length;
			for (var i : int = 0; i < len; i++) {
				var bone : BoneData = _bones[i];
				if (bone.name == boneName) return bone;
			}

			return null;
		}
	
		/** @return -1 if the bone was not found. */
		public function findBoneIndex (boneName : String) : int{
			if (boneName == null) throw new Error("boneName cannot be null.");
			var len : int = _bones.length;
			for (var i : int = 0; i < len; i++){
				if (_bones[i].name == boneName) 
					return i;
			}
			return -1;
		}
	
		// --- Slots.
	
		public function addSlot ( slot : SlotData ) : void {
			if (slot == null) throw new Error("slot cannot be null.");
			slots.push(slot);
		}
	
		public function get slots () : Vector.<SlotData>{
			return _slots;
		}
	
		/** @return May be null. */
		public function findSlot (slotName : String) : SlotData{
			if (slotName == null) throw new Error("slotName cannot be null.");
			var len : int = _slots.length;
			for (var i : int = 0; i < len; i++){
				var slot : SlotData = _slots[i];
				if (slot.name == slotName) return slot;
			}
			return null;
		}
	
		/** @return -1 if the bone was not found. */
		public function findSlotIndex (slotName : String) : int {
			if (slotName == null) throw new Error("slotName cannot be null.");
			var len : int = _slots.length;
			for (var i : int = 0; i < len; i++){
				if (_slots[i].name == slotName) return i;
			}
			return -1;
		}
	
		// --- Skins.
	
		/** @return May be null. */
		public function get defaultSkin() : Skin{
			return _defaultSkin;
		}
	
		/** @param defaultSkin May be null. */
		public function set defaultSkin(skin : Skin) : void {
			this._defaultSkin = skin;
		}
	
		public function addSkin(skin : Skin) : void {
			if (skin == null) throw new Error("skin cannot be null.");
			_skins.push(skin);
		}
	
		/** @return May be null. */
		public function getSkin (skinName : String) : Skin{
			if (skinName == null) throw new Error("skinName cannot be null.");
			var len : int = _skins.length;
			for (var i : int = 0; i < len; i++){
				var skin : Skin = _skins[i];
				if (skin.name == skinName) return skin;
			}
			return null;
		}
	
		/** Returns all named skins. This does not include the default skin. */
		public function get skins() : Vector.<Skin> {
			return _skins;
		}
		
		public function toString () : String {
			return name != null ? name : super.toString();
		}
	}
}
