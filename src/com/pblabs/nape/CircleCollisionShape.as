package com.pblabs.nape
{
	import flash.geom.Point;
	
	import nape.geom.Vec2;
	import nape.shape.Circle;
	import nape.shape.Shape;

	public class CircleCollisionShape extends CollisionShape
	{
		[EditorData(defaultValue="1")]
		public function get radius():Number
		{
			return _radius;
		}
		
		public function set radius(value:Number):void
		{
			_radius = value;
			
			if (_parent)
				_parent.buildCollisionShapes();
		}
		
		public function get position():Point
		{
			return _position;
		}
		
		public function set position(value:Point):void
		{
			_position = value;
			
			if (_parent)
				_parent.buildCollisionShapes();
		}
		
		public function CircleCollisionShape()
		{
			super();
		}
		
		override protected function doCreateShape():Shape
		{
			var invScale:Number = NapeManagerComponent(_parent.spatialManager).inverseScale;
			
			var nPos:Vec2 = new Vec2((_position.x*shapeScale.x) * invScale, (_position.y*shapeScale.y) * invScale);
			
			return new Circle( ((_radius * Math.sqrt(shapeScale.x * shapeScale.y)) * invScale) , nPos);
		}
		
		private var _radius:Number = 20.0;
		private var _position:Point = new Point(0, 0);
	}
}