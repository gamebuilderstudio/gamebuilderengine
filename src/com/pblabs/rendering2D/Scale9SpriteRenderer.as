package com.pblabs.rendering2D
{
	import com.pblabs.engine.PBUtil;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public final class Scale9SpriteRenderer extends SpriteRenderer
	{
		private var _scale9Region:Rectangle = new Rectangle(0,0,5,5);
		
		public function Scale9SpriteRenderer()
		{
			super();
		}
		
		override public function onFrame(elapsed:Number):void
		{
			super.onFrame(elapsed);
			
			if(_imageDataDirty)
				bitmapData = originalBitmapData;
		}
		
		public function get scale9Region():Rectangle
		{
			return _scale9Region
		}
		public function set scale9Region(region : Rectangle):void
		{
			_scale9Region = region;
			_imageDataDirty = true;
		}
		
		override public function set size(value:Point):void
		{
			if(_size && value && (_size.x != value.x || _size.y != value.y))
				_imageDataDirty = true;
			super.size = value;
		}
		
		override public function set scale(value:Point):void
		{
			if(_scale && value && (_scale.x != value.x || _scale.y != value.y)){
				if(value.x < 0) value.x = .1;
				if(value.y < 0) value.y = .1;
				_imageDataDirty = true;
			}
			super.scale = value;
		}

		override public function set bitmapData(value:BitmapData):void
		{
			if((!bitmap || !(bitmap is Scale9Bitmap)) && value)
				bitmap = new Scale9Bitmap(value);
			
			if(bitmap && _scale9Region)
				bitmap.scale9Grid = _scale9Region;
			
			super.bitmapData = value;
			
			_imageDataDirty = false;
		}
		
		public function get originalScalableBitmapData() : BitmapData
		{
			return originalBitmapData;
		}
		
		override public function updateTransform(updateProps:Boolean = false):void
		{
			if(!displayObject)
				return;
			
			if(updateProps)
				updateProperties();
			
			var tmpScale : Point = combinedScale;
			_transformMatrix.identity();
			//_transformMatrix.scale(_scale.x, _scale.y);
			_transformMatrix.translate(-_registrationPoint.x, -_registrationPoint.y);
			_transformMatrix.rotate(PBUtil.getRadiansFromDegrees(_rotation + _rotationOffset));
			_transformMatrix.translate((_position.x + _positionOffset.x), (_position.y + _positionOffset.y));
			
			displayObject.transform.matrix = _transformMatrix;
			if(bitmap){
				(bitmap as Scale9Bitmap).width = (this._size.x * _scale.x);
				(bitmap as Scale9Bitmap).height = (this._size.y * _scale.y);
			}
			displayObject.alpha = _alpha;
			displayObject.blendMode = _blendMode;
			displayObject.visible = (alpha > 0);
			
			_transformDirty = false;
		}

		protected function get isValidRegion() : Boolean {
			if(!originalBitmapData || !_scale9Region) return false;
			return _scale9Region.right <= originalBitmapData.width && _scale9Region.bottom <= originalBitmapData.height;
		}
	}
}