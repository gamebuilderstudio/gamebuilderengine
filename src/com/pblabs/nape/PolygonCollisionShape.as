package com.pblabs.nape
{
	import flash.geom.Point;
	
	import nape.geom.GeomPoly;
	import nape.geom.Vec2;
	import nape.geom.Vec2List;
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

			if(!_vertices) 
				generateBox(_parent.size.x/2, _parent.size.y/2);
			
			for (var i:int = 0; i < _napeVertList.length; i++)
				_napeVertList[i].dispose();
			
			_napeVertList.length = 0;
			for (i = 0; i < _vertices.length; i++)
				_napeVertList.push( Vec2.weak(((_vertices[i].x * shapeScale.x) * invScale), ((_vertices[i].y * shapeScale.y) * invScale)) );
			
			var polygon : Polygon;
			/*if(_shape)
			{
				polygon = _shape as Polygon;
				polygon.localVerts.clear()
				polygon.localVerts.merge( Vec2List.fromVector(_napeVertList) );
			}else{*/
				polygon = new Polygon(_napeVertList);
			//}
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
		private var _napeVertList : Vector.<Vec2> = new Vector.<Vec2>();
	}
}