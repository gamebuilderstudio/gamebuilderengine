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
			
				
			_imageContainer.x = _worldX;
			_imageContainer.y = _worldY;
			_imageContainer.rotation = _worldRotation;
			_imageContainer.scaleX = _worldScaleX;
			_imageContainer.scaleY = _worldScaleY;
				
			_image.x = -centerX;
			_image.y = -centerY;
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