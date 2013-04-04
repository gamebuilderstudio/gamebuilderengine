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
	import flash.display.Sprite;
	
	import spine.utils.Color;
	import spine.utils.ColorUtil;

	public class Skeleton 
	{
		public var bones : Vector.<Bone>;
		public var slots : Vector.<Slot>;
		public var drawOrder : Vector.<Slot>;
		
		public var flipX : Boolean;
		public var flipY : Boolean;
		public var skin : Skin;
		public var color : Color;
		public var time : Number;
	
		protected var _data : SkeletonData;

		public function Skeleton (data : SkeletonData) : void {
			if (data == null) 
				throw new Error("data cannot be null.");
			this._data = data;
			
			var bones : Vector.<Bone> = new Vector.<Bone>(_data.bones.length);
			var len : int = _data.bones.length;
			for(var i : int = 0; i < len; i++) {
				var boneData : BoneData = _data.bones[i];
				var parent : Bone = boneData.parent == null ? null : bones[_data.bones.indexOf(boneData.parent)];
				bones[i] = new Bone(boneData, parent);
				//trace("Adding Bone ["+i+"] = "+ bones[i].data.name);
			}
			//trace("Adding Bones");
			this.bones = bones;
			
			var slots : Vector.<Slot> = new Vector.<Slot>(_data.slots.length);
			var drawOrder : Vector.<Slot> = new Vector.<Slot>(_data.slots.length);
			len = _data.slots.length;
			for(i = 0; i < len; i++) {
				var slotData : SlotData = _data.slots[i];
				var bone : Bone = bones[_data.bones.indexOf(slotData.boneData)];
				var slot : Slot = new Slot(slotData, this, bone);
				//trace("Adding Slot ["+i+"] = "+ slot.data.name);
				slots[i] = slot;
				drawOrder[i] = slot;
			}
			this.slots = slots;
			this.drawOrder = drawOrder;
			
			this.color = new Color(1,1,1,1);
		}
		
		public function clone() : Skeleton {
			var skeleton : Skeleton = new Skeleton( this._data );

			skeleton.bones = new Vector.<Slot>(this.bones.length);
			for each(var bone : Bone in this.bones) {
				//var parent : Bone = this.bones.get(this.bones.indexOf(bone.parent, true));
				skeleton.bones.push( bone.clone() ); // Perform clone
			}
	
			skeleton.slots = new Vector.<Slot>(this.slots.length);
			for each(var slot : Slot in this.slots) {
				//bone = bones.get(this.bones.indexOf(slot.bone, true));
				var newSlot : Slot = slot.clone();
				skeleton.slots.push(newSlot);
			}
	
			skeleton.drawOrder = new Vector.<Slot>(slots.length);
			for each(slot in this.drawOrder)
				skeleton.drawOrder.push(slot.clone());
	
			skeleton.skin = this.skin;
			skeleton.color = this.color;
			skeleton.time = this.time;
			return skeleton;
		}
	
		/** Updates the world transform for each bone. */
		public function updateWorldTransform () : void{
			var bones : Vector.<Bone> = this.bones;
			var len : int = bones.length;
			for (var i : int = 0; i < len; i++)
				bones[i].updateWorldTransform(this.flipX, this.flipY);
		}
	
		/** Sets the bones and slots to their bind pose values. */
		public function setToBindPose () : void {
			setBonesToBindPose();
			setSlotsToBindPose();
		}
		
		public function setBonesToBindPose () : void {
			var bones : Vector.<Bone> = this.bones;
			var len : int = bones.length;
			for (var i : int = 0; i < len; i++)
				bones[i].setToBindPose();
		}
		
		public function setSlotsToBindPose () : void {
			var slots : Vector.<Slot> = this.slots;
			var len : int  = slots.length;
			for (var i : int = 0; i < len; i++)
				slots[i].setToBindPose();
		}
	
		public function draw (displayObject : *) : void {
			var drawOrder : Vector.<Slot> = this.drawOrder;
			var len : int = drawOrder.length;
			for (var i : int = 0; i < len; i++){
				var slot : Slot = drawOrder[i];
				var attachment : Attachment = slot.attachment;
				if (attachment != null) {
					attachment.draw(displayObject, slot);
				}
			}
		}
	
		public function drawDebug (displayObject : *) : void {
			var renderer : Sprite = displayObject as Sprite;
			renderer.graphics.clear();
			renderer.graphics.lineStyle(4, 0xFFFFFF, .4);
			for (var i : int = 0; i < bones.length; i++) {
				var bone : Bone = bones[i];
				if (bone.parent == null) continue;
				var x : Number = bone.data.length * bone.m00 + bone.worldX;
				var y : Number = bone.data.length * bone.m10 + bone.worldY;
				renderer.graphics.moveTo(bone.worldX, -bone.worldY);
				renderer.graphics.lineTo(x, -y);
			}
		}
	
		public function get data () : SkeletonData {
			return _data;
		}
	
		/*
		public function get Bones () : Vector.<Bone> {
			return bones;
		}
	
		public function get slots () : Vector.<Slot> {
		return slots;
		}

		/** @return May return null. */
		public function get rootBone () : Bone {
			if (this.bones.length == 0) return null;
			return this.bones[0];
		}
	
		/** @return May be null. */
		public function findBone (boneName : String) : Bone {
			if (boneName == null) throw new Error("boneName cannot be null.");
			var bones : Vector.<Bone> = this.bones;
			var len : int = bones.length;
			for (var i : int = 0; i < len; i++) {
				var bone : Bone = bones[i];
				if (bone.data.name == boneName) return bone;
			}
			return null;
		}
		
		/** @return -1 if the bone was not found. */
		public function findBoneIndex (boneName : String) : int {
			if (boneName == null) throw new Error("boneName cannot be null.");
			var len : int = bones.length;
			for (var i : int = 0; i < len; i++)
				if (bones[i].data.name == boneName) return i;
			return -1;
		}

		/** @return May be null. */
		public function findSlot (slotName : String) : Slot {
			if (slotName == null) 
				throw new Error("slotName cannot be null.");
			var len : int =  slots.length;
			for (var i : int = 0; i < len; i++){
				var slot : Slot = slots[i];
				if (slot.data.name == slotName) return slot;
			}
			return null;
		}
	
		/** @return -1 if the bone was not found. */
		public function findSlotIndex (slotName : String) : int{
			if (slotName == null) throw new Error("slotName cannot be null.");
			var len : int = slots.length;
			for (var i : int = 0; i < len; i++)
				if (slots[i].data.name == slotName) return i;
			return -1;
		}
		
		/** Returns the slots in the order they will be drawn. The returned array may be modified to change the draw order. */
		public function getDrawOrder () : Vector.<Slot> {
			return drawOrder;
		}
	
		/** Sets a skin by name.
		 * @see #setSkin(Skin) */
		public function setSkinByName (skinName : String) : void {
			var skin : Skin = _data.getSkin(skinName);
			if (skin == null) throw new Error("Skin not found: " + skinName);
			setSkin(skin);
		}
	
		/** Sets the skin used to look up attachments not found in the {@link SkeletonData#getDefaultSkin() default skin}. Attachments
		 * from the new skin are attached if the corresponding attachment from the old skin is currently attached.
		 * @param newSkin May be null. */
		public function setSkin (newSkin : Skin) : void {
			if (skin != null && newSkin != null) newSkin.attachAll(this, skin);
			skin = newSkin;
		}
	
		/** @return May be null. */
		public function getAttachmentByName (slotName : String,  attachmentName : String) : Attachment {
			return getAttachment(_data.findSlotIndex(slotName), attachmentName);
		}
	
		/** @return May be null. */
		public function getAttachment (slotIndex : int, attachmentName : String) : Attachment {
			if (attachmentName == null) 
				throw new Error("attachmentName cannot be null.");
			if (this._data.defaultSkin != null) {
				var attachment : Attachment = this._data.defaultSkin.getAttachment(slotIndex, attachmentName);
				if (attachment != null) 
					return attachment;
			}
			if (this.skin != null) 
				return this.skin.getAttachment(slotIndex, attachmentName);
			return null;
		}
	
		/** @param attachmentName May be null. */
		public function setAttachment (slotName : String, attachmentName : String) : void {
			if (slotName == null) throw new Error("slotName cannot be null.");
			if (attachmentName == null) throw new Error("attachmentName cannot be null.");
			
			var len : int = slots.length;
			for (var i : int = 0; i < len; i++){
				var slot : Slot = slots[i];
				if (slot.data.name == slotName) {
					slot.attachment = getAttachment(i, attachmentName);
					return;
				}
			}
			throw new Error("Slot not found: " + slotName);
		}
	
		public function update (delta : Number) : void {
			time += delta;
		}
		
		public function toString () : String {
			return _data.name != null ? _data.name : super.toString();
		}
	}
}
