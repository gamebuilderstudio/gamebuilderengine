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