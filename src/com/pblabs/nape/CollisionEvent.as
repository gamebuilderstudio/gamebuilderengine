package com.pblabs.nape
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import nape.dynamics.CollisionArbiter;
	
	public class CollisionEvent extends Event
	{
		public static const COLLISION_EVENT:String = "COLLISION_EVENT";
		public static const COLLISION_STOPPED_EVENT:String = "COLLISION_STOPPED_EVENT";
		public static const ONGOING_COLLISION:String = "ONGOING_COLLISION";
		public static const PRE_COLLISION_EVENT:String = "PRE_COLLISION_EVENT";
		
		public var collider:NapeSpatialComponent = null;
		public var collidee:NapeSpatialComponent = null;
		public var colliderShape:CollisionShape = null;
		public var collideeShape:CollisionShape = null;
		public var normal:Point = null;
		public var collisionArbiter:CollisionArbiter = null;
		
		public function CollisionEvent(type:String, collider:NapeSpatialComponent, collidee:NapeSpatialComponent, colliderShape : CollisionShape, collideeShape : CollisionShape, normal:Point, collisionArbiter : CollisionArbiter)
		{
			super(type, bubbles, cancelable);
			this.collider = collider;
			this.collidee = collidee;
			this.colliderShape = colliderShape;
			this.collideeShape = collideeShape;
			this.collisionArbiter = collisionArbiter;
			this.normal = normal;
		}
		
		override public function clone():Event
		{
			return new CollisionEvent(type, collider, collidee, colliderShape, collideeShape, normal, collisionArbiter);
		}
	}
}