/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.box2D
{
   import Box2DAS.Dynamics.Contacts.*;
   import Box2DAS.Collision.b2ContactPoint;
   
   import flash.events.Event;
   import flash.geom.Point;

   public class CollisionEvent extends Event
   {
      public static const COLLISION_EVENT:String = "COLLISION_EVENT";
	  public static const PRE_COLLISION_EVENT:String = "PRE_COLLISION_EVENT";
      public static const COLLISION_STOPPED_EVENT:String = "COLLISION_STOPPED_EVENT";
      
      public var collider:Box2DSpatialComponent = null;
      public var collidee:Box2DSpatialComponent = null;
      public var normal:Point = null;
	  public var contact:b2Contact = null;
      
	  public function CollisionEvent(type:String, contact:b2Contact, bubbles:Boolean=false, cancelable:Boolean=false)
      {
		 collider = contact.GetFixtureA().GetUserData() as Box2DSpatialComponent;
		 collidee = contact.GetFixtureB().GetUserData() as Box2DSpatialComponent;
		 normal = new Point(contact.GetManifold().localNormal.x, contact.GetManifold().localNormal.y);
		 this.contact = contact;
         
         super(type, bubbles, cancelable);
      }
   }
}