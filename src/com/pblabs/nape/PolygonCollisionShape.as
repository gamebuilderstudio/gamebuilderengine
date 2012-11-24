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
			var invScale:Number = (_parent.spatialManager as NapeManagerComponent).inverseScale;

			if(!_vertices) generateBox(_parent.size.x/2, _parent.size.y/2);
			var poly:GeomPoly = new GeomPoly();
			for (var i:int = 0; i < _vertices.length; i++)
				poly.push(new Vec2((_vertices[i].x * shapeScale.x) * invScale, (_vertices[i].y * shapeScale.y) * invScale));

			var polygon : Polygon = new Polygon(poly);
			return polygon;
		}
		
		public function generateBox(halfWidth:Number, halfHeight:Number):void {
			_vertices = new Array();
			_vertices.push(new Point( -halfWidth, -halfHeight));
			_vertices.push(new Point( halfWidth, -halfHeight));
			_vertices.push(new Point( halfWidth, halfHeight));
			_vertices.push(new Point( -halfWidth, halfHeight));
		}
		
		private var _vertices:Array;
	}
}