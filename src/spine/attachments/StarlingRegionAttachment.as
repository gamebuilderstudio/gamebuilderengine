/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2012 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
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
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import spine.Bone;
	import spine.Slot;
	import spine.utils.MathUtils;
	
	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	/** Attachment that displays a Starling texture region. */
	public class StarlingRegionAttachment extends RegionAttachment {

		protected var _region : Rectangle;
		protected var _texture : Texture;
		protected var _image : Image;
		protected var _frame : Rectangle;
		
		private var _imgX : Number = 0;
		private var _imgY : Number = 0;
		private var _imgRotation : Number = 0;
		private var _imgScaleX : Number = 1;
		private var _imgScaleY : Number = 1;
		
		public function StarlingRegionAttachment (name : String) : void {
			super(name);
		}
		
		override public function draw (displayObject : *, slot : Slot) : void {
			if (_region == null) throw new Error("RegionAttachment is not setup: " + this);
			if (_texture == null) throw new Error("RegionAttachment is not setup: " + this);
			
			var batch : QuadBatch = displayObject as QuadBatch;
			if(!_image){
				_image = new Image(_texture);
			}
			
			updateWorldPosition(slot.bone, slot.skeleton.flipX, slot.skeleton.flipY);
			
			var centerX : Number = this.width/2;
			var centerY : Number = this.height/2;
				
			/*_image.width = this.width;
			_image.height = this.height;*/
			_image.pivotX = centerX * this._imgScaleX;
			_image.pivotY = centerY * this._imgScaleY;
			
			_image.x = this._imgX;
			_image.y = this._imgY;
			_image.rotation = this._imgRotation;
			_image.scaleX = this._imgScaleX;
			_image.scaleY = this._imgScaleY;
			
			batch.addImage(_image);
		}
		
		override public function updateWorldPosition(bone : Bone, flipX : Boolean = false, flipY : Boolean = false):void
		{
			this._imgX = bone.worldX + this.x * bone.m00 + this.y * bone.m01;
			this._imgY = -(bone.worldY + this.x * bone.m10 + this.y * bone.m11);
			this._imgRotation = MathUtils.getRadiansFromDegrees(-(bone.worldRotation + this.rotation));
			this._imgScaleX = bone.worldScaleX + this.scaleX - 1;
			this._imgScaleY = bone.worldScaleY + this.scaleY - 1;
			
			if(flipX){
				this._imgScaleX = -this._imgScaleX;
				this._imgRotation = -this._imgRotation;
			}
			if(flipY){
				this._imgScaleY = -this._imgScaleY;
				this._imgRotation = -this._imgRotation;
			}
		}
		
		public function set region (region : Rectangle) : void {
			if (region == null) throw new Error("region cannot be null.");
			_region = region;
			updateOffset();
		}
		
		public function get region () : Rectangle {
			if (_region == null) throw new Error("RegionAttachment is not resolved: " + this);
			return _region;
		}
		
		public function set frame (frame : Rectangle) : void {
			_frame = frame;
			if(_region && _frame)
				updateOffset();
		}
		
		public function get frame () : Rectangle {
			return _frame;
		}
		
		public function set texture (texture : Texture) : void {
			if (texture == null) throw new Error("Texture cannot be null.");
			_texture = texture;
		}
		
		public function get texture () : Texture {
			if (_texture == null) throw new Error("RegionAttachment is not resolved: " + this);
			return _texture;
		}
		
	}
}