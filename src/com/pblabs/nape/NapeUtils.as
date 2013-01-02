package com.pblabs.nape
{
	import com.pblabs.physics.IPhysics2DSpatial;
	
	import flash.geom.Point;

	public final class NapeUtils
	{
		public function NapeUtils()
		{
		}
		
		public static function inCollision(caller : IPhysics2DSpatial, event : CollisionEvent):Boolean
		{
			return (caller == event.collidee) || (caller == event.collider) ? true : false;
		}

		public static function getCollider(caller : IPhysics2DSpatial, event : CollisionEvent, self : Boolean = false):IPhysics2DSpatial
		{
			return (self && caller == event.collidee) || (!self && caller == event.collider) ? event.collidee : event.collider;
		}
		
		public static function normalizePointVector(point : Point):Point
		{
			var magnitude : Number = getMagnitude(point);
			point.x /= magnitude;
			point.y /= magnitude;
			return point;
		}
		
		public static function getMagnitude(point : Point):Number
		{
			return Math.sqrt((point.x * point.x) + (point.y * point.y));
		}
	}
}