package com.pblabs.rendering2D
{
	import com.pblabs.engine.core.ObjectType;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class BitmapShapeRenderer extends SimpleShapeRenderer implements ICopyPixelsRenderer
	{
		static protected const zeroPoint:Point = new Point();

		protected var bitmap:Bitmap;
		protected var _smoothing:Boolean = false;
		
		public function BitmapShapeRenderer()
		{
			super();
			_smoothing = true;
			_lineSize = 0;
			_lineAlpha = 0;
			_size = new Point(100,100);
		}
		
		public function isPixelPathActive(objectToScreen:Matrix):Boolean
		{
			// No rotation/scaling/translucency/blend modes
			return (objectToScreen.a == 1 && objectToScreen.b == 0 && objectToScreen.c == 0 && objectToScreen.d == 1 && alpha == 1 && blendMode == BlendMode.NORMAL );//&& (displayObject.filters.length == 0)
		}
		
		public function drawPixels(objectToScreen:Matrix, renderTarget:BitmapData):void
		{
			// Draw to the target.
			if (bitmap.bitmapData!=null){
				renderTarget.copyPixels(bitmap.bitmapData, bitmap.bitmapData.rect, objectToScreen.transformPoint(zeroPoint), null, null, true);
			}
		}

		override public function pointOccupied(worldPosition:Point, mask:ObjectType):Boolean
		{
			if(!bitmap || !bitmap.bitmapData || !scene)
				return false;
			
			// Figure local position.
			var localPos:Point = transformWorldToObject(worldPosition);
			return bitmap.bitmapData.hitTest(zeroPoint, 0x01, localPos);
		}
		
		override protected function onRemove():void
		{
			if(bitmap && bitmap.bitmapData){
				bitmap.bitmapData.dispose();
			}
			super.onRemove();
		}
		
		override public function redraw():void
		{
			if(bitmap){
				if(bitmap.bitmapData)
					bitmap.bitmapData.dispose();
				bitmap.bitmapData = null;
			}
			if(!_size || _size.x == 0 || _size.y == 0 || (!isCircle && !isSquare) ) {
				return;
			}
			
			if(!_shape)
				_shape = new Sprite();

			// Get references.
			var s:Sprite = _shape;
			if(!s)
				throw new Error("displayObject null or not a Sprite!");
			var g:Graphics = s.graphics;
			
			// Don't forget to clear.
			g.clear();
			
			// Prep line/fill settings.
			g.lineStyle(lineSize, lineColor, lineAlpha);
			g.beginFill(fillColor, fillAlpha);
			
			// Draw one or both shapes.
			if(isSquare)
				g.drawRect(0, 0, size.x, size.y);

			if(isCircle){
				var radiansX : Number = 180 * (Math.PI/180);
				var radiansY : Number = -90 * (Math.PI/180);
				var x : int = radius * Math.cos(radiansX);
				var y : int = radius * Math.sin(radiansY);
				g.drawCircle(-x, -y, radius);
			}
			
			g.endFill();
			
			if(!bitmap){
				bitmap = new Bitmap();
				bitmap.pixelSnapping = PixelSnapping.AUTO;
				bitmap.blendMode = this._blendMode;
			}
			
			if(isCircle || isSquare){
				var bounds : Rectangle = s.getBounds( s );
				var m : Matrix = new Matrix();
				//_registrationPoint = new Point(-bounds.topLeft.x, -bounds.topLeft.y);
				bitmap.bitmapData = new BitmapData(bounds.width, bounds.height, true, 0x000000);
				bitmap.bitmapData.draw(s,m, s.transform.colorTransform, s.blendMode );
				bitmap.smoothing = this._smoothing;
			}
			if(displayObject != bitmap)
				displayObject = bitmap;
			_shapeDirty = false;
		}
		
		override public function set size(value:Point):void
		{
			if(this._size.x != value.x || this._size.y != value.y){
				_shapeDirty = true;
			}
			super.size = value;
			if(_shapeDirty){
				_radius = 0.5 * Math.sqrt(_size.x * _size.y);
			}
		}
		
		
		override public function set blendMode(value:String):void
		{
			super.blendMode = value;
			if(bitmap)
				bitmap.blendMode = this._blendMode;
		}

		/**
		 * @see Bitmap.smoothing 
		 */
		[EditorData(ignore="true")]
		public function set smoothing(value:Boolean):void
		{
			_smoothing = value;
			if(bitmap)
				bitmap.smoothing = value;
		}
		
		public function get smoothing():Boolean
		{
			return _smoothing;
		}
		
		public function get bitmapShape():Bitmap{ return bitmap; }
	}
}