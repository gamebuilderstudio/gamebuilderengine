package com.pblabs.nape
{
	import flash.geom.Point;
	
	import nape.geom.GeomPoly;
	import nape.geom.Vec2;
	import nape.shape.Polygon;
	import nape.shape.Shape;

	public class PolygonCollisionShape extends CollisionShape
	{
		public function PolygonCollisionShape()
		{
			super();
		}
		
		//[TypeHint(type="nape.geom.Vec2")]
		[TypeHint(type="flash.geom.Point")]
		public function get vertices():Array
		{
			return _vertices;
		}
		
		public function set vertices(value:Array):void
		{ 
			_vertices = value;
			
			if (_parent)
				_parent.buildCollisionShapes();
		}
		
		override protected function doCreateShape():Shape
		{
			var invScale:Number = NapeManagerComponent(_parent.spatialManager).inverseScale;
			var halfSize:Point = new Point(_parent.size.x * 0.5, _parent.size.y * 0.5);
			var poly:GeomPoly = new GeomPoly();
			
			for each ( var vec:Point in _vertices )
			{
				poly.push(new Vec2(vec.x * halfSize.x * invScale, vec.y * halfSize.y * invScale));
			}
				
			return new Polygon(poly);
		}
		
		private var _vertices:Array;
	}
}