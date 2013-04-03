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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import spine.Bone;
	import spine.Slot;
	import spine.utils.MathUtils;
	
	/** Attachment that displays a Starling texture region. */
	public class Basic2DRegionAttachment extends RegionAttachment {

		protected var offset : Vector.<Number> = new Vector.<Number>(); 
		protected var worldPosition : Rectangle = new Rectangle(); 

		protected var _region : Rectangle;
		protected var _imageData : BitmapData;
		protected var _regionData : BitmapData;
		protected var _frame : Rectangle;
		protected var _image : Bitmap;
		protected var _imageContainer : Sprite = new Sprite();
		
		public function Basic2DRegionAttachment (name : String) : void {
			super(name);
		}
		
		override public function draw (displayObject : *, slot : Slot) : void {
			if (_region == null) throw new Error("RegionAttachment is not setup: " + this);
			if (_imageData == null) throw new Error("RegionAttachment is not setup: " + this);
			
			var container : Sprite = displayObject as Sprite;

			var centerX : Number = width / 2;
			var centerY : Number = height / 2;
			if(!_image){
				_regionData = new BitmapData(_region.width, _region.height);
				_regionData.copyPixels(_imageData, _region, new Point() );
				_image = new Bitmap(_regionData);
				_imageContainer.addChild(_image);
				_image.smoothing = true;
				container.addChild(_imageContainer);
			}
			
			updateWorldPosition(slot.bone, slot.skeleton.flipX, slot.skeleton.flipY);
			
				
			_imageContainer.x = (slot.bone.worldX + this.x * slot.bone.m00 + this.y * slot.bone.m01);
			_imageContainer.y = (-(slot.bone.worldY + this.x * slot.bone.m10 + this.y * slot.bone.m11));
			_imageContainer.rotation = -(slot.bone.worldRotation + this.rotation);
			_imageContainer.scaleX = slot.bone.worldScaleX + this.scaleX - 1;
			_imageContainer.scaleY = slot.bone.worldScaleY + this.scaleY - 1;
				
			if(slot.skeleton.flipX){
				_imageContainer.scaleX = -_image.scaleX;
				_imageContainer.rotation = -_image.rotation;
			}
			if(slot.skeleton.flipY){
				_imageContainer.scaleY = -_image.scaleY;
				_imageContainer.rotation = -_image.rotation;
			}
			_image.x = -centerX*_imageContainer.scaleX;
			_image.y = -centerY*_imageContainer.scaleY;
		}
		
		override public function updateWorldPosition(bone : Bone, flipX : Boolean = false, flipY : Boolean = false):void
		{
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
		
		public function set image (imageData : BitmapData) : void {
			if (imageData == null) throw new Error("Image cannot be null.");
			_imageData = imageData;
		}
		
		public function get image () : BitmapData {
			if (_imageData == null) throw new Error("RegionAttachment is not resolved: " + this);
			return _imageData;
		}
		
	}
}