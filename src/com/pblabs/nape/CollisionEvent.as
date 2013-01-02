package com.pblabs.nape
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import nape.dynamics.CollisionArbiter;
	import nape.dynamics.Contact;
	import nape.dynamics.ContactList;
	
	public class CollisionEvent extends Event
	{
		public static const COLLISION_EVENT:String = "COLLISION_EVENT";
		public static const COLLISION_STOPPED_EVENT:String = "COLLISION_STOPPED_EVENT";
		public static const ONGOING_COLLISION:String = "ONGOING_COLLISION";
		public static const PRE_COLLISION_EVENT:String = "PRE_COLLISION_EVENT";
		
		public var collider:NapeSpatialComponent = null;
		public var collidee:NapeSpatialComponent = null;
		public var normal:Point = null;
		public var contacts:ContactList = null;
		public var collisionArbiter:CollisionArbiter = null;
		
		public function CollisionEvent(type:String, collider:NapeSpatialComponent, collidee:NapeSpatialComponent, normal:Point, contacts:ContactList, arbiter:CollisionArbiter)
		{
			super(type, bubbles, cancelable);
			this.collider = collider;
			this.collidee = collidee;
			this.normal = normal;
			this.contacts = contacts;
			this.collisionArbiter = arbiter;
		}
		
		override public function clone():Event
		{
			return new CollisionEvent(type, collider, collidee, normal, contacts, collisionArbiter);
		}
	}
}