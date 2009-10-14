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
   import Box2D.Collision.b2ContactPoint;
   
   import flash.events.Event;
   import flash.geom.Point;

   public class CollisionEvent extends Event
   {
      public static const COLLISION_EVENT:String = "COLLISION_EVENT";
      public static const COLLISION_STOPPED_EVENT:String = "COLLISION_STOPPED_EVENT";
      
      public var collider:Box2DSpatialComponent = null;
      public var collidee:Box2DSpatialComponent = null;
      public var normal:Point = null;
      public var contactPoint:b2ContactPoint = null;
      
      public function CollisionEvent(type:String, point:b2ContactPoint, bubbles:Boolean=false, cancelable:Boolean=false)
      {
         collider = point.shape1.m_userData as Box2DSpatialComponent;
         collidee = point.shape2.m_userData as Box2DSpatialComponent;
         normal = new Point(point.normal.x, point.normal.y);
         contactPoint = point;
         
         super(type, bubbles, cancelable);
      }
   }
}