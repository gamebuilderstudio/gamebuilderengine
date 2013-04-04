/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2012 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package spine.attachments
{
	import flash.geom.Rectangle;
	
	import spine.Attachment;
	import spine.Bone;
	import spine.Slot;
	import spine.utils.MathUtils;
	
	/** Attachment that displays a texture or sprite region. */
	public class RegionAttachment extends Attachment {
		public var x : Number;
		public var y : Number;
		public var scaleX : Number = 1;
		public var scaleY : Number = 1;
		public var rotation : Number = 0;
		public var width : Number;
		public var height : Number;

		protected var _worldX : Number = 0;
		protected var _worldY : Number = 0;
		protected var _worldRotation : Number = 0;
		protected var _worldScaleX : Number = 1;
		protected var _worldScaleY : Number = 1;

		public function RegionAttachment (name : String) : void {
			super(name);
		}
		
		/**
		 * Calculate the region offset position from the bone that it is attached to
		 * 
		 * Calculates and stores the position and size of the attached image to the offset property
		 **/ 
		public function updateOffset():void
		{
			
		}
		
		public function updateWorldPosition(bone : Bone, flipX : Boolean = false, flipY : Boolean = false):void
		{
			this._worldX = bone.worldX + this.x * bone.m00 + this.y * bone.m01;
			this._worldY = -(bone.worldY + this.x * bone.m10 + this.y * bone.m11);
			this._worldRotation = -(bone.worldRotation + this.rotation);
			this._worldScaleX = bone.worldScaleX + this.scaleX - 1;
			this._worldScaleY = bone.worldScaleY + this.scaleY - 1;
			
			if(flipX){
				this._worldScaleX = -this._worldScaleX;
				this._worldRotation = -this._worldRotation;
			}
			if(flipY){
				this._worldScaleY = -this._worldScaleY;
				this._worldRotation = -this._worldRotation;
			}
		}
	}
}