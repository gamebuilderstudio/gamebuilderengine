package com.pblabs.nape
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import nape.dynamics.Contact;
	import nape.dynamics.ContactList;
	
	public class CollisionEvent extends Event
	{
		public static const BEGIN_COLLISION:String = "BEGIN_COLLISION";
		public static const ONGOING_COLLISION:String = "ONGOING_COLLISION";
		public static const END_COLLISION:String = "END_COLLISION";
		
		public var collider:NapeSpatialComponent = null;
		public var collidee:NapeSpatialComponent = null;
		public var normal:Point = null;
		public var contacts:ContactList = null;
		
		public function CollisionEvent(type:String, collider:NapeSpatialComponent, collidee:NapeSpatialComponent, normal:Point, contacts:ContactList)
		{
			super(type, bubbles, cancelable);
			this.collider = collider;
			this.collidee = collidee;
			this.normal = normal;
			this.contacts = contacts;
		}
		
		override public function clone():Event
		{
			return new CollisionEvent(type, collider, collidee, normal, contacts);
		}
	}
}