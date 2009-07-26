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
   import Box2D.Dynamics.Contacts.b2ContactResult;
   import Box2D.Dynamics.b2ContactListener;
   
   import flash.utils.Dictionary;

   public class ContactListener extends b2ContactListener
   {
      public override function Add(point:b2ContactPoint):void
      {
         var spatial1:Box2DSpatialComponent = point.shape1.m_userData as Box2DSpatialComponent;
         var spatial2:Box2DSpatialComponent = point.shape2.m_userData as Box2DSpatialComponent;
         
         if (!shape1Dictionary[spatial1])
            shape1Dictionary[spatial1] = 0;
         
         if (!shape1Dictionary[spatial2])
            shape1Dictionary[spatial2] = 0;
         
         spatial1.owner.eventDispatcher.dispatchEvent(new CollisionEvent(CollisionEvent.COLLISION_EVENT, point));
         spatial2.owner.eventDispatcher.dispatchEvent(new CollisionEvent(CollisionEvent.COLLISION_EVENT, point));
         
         shape1Dictionary[spatial1]++;
         shape1Dictionary[spatial2]++;
      }
      
      public override function Persist(point:b2ContactPoint):void
      {
      }
      
      public override function Remove(point:b2ContactPoint):void
      {
         var spatial1:Box2DSpatialComponent = point.shape1.m_userData as Box2DSpatialComponent;
         var spatial2:Box2DSpatialComponent = point.shape2.m_userData as Box2DSpatialComponent;
         
         shape1Dictionary[spatial1]--;
         shape1Dictionary[spatial2]--;
         
         spatial1.owner.eventDispatcher.dispatchEvent(new CollisionEvent(CollisionEvent.COLLISION_STOPPED_EVENT, point));
         spatial2.owner.eventDispatcher.dispatchEvent(new CollisionEvent(CollisionEvent.COLLISION_STOPPED_EVENT, point));
      }
      
      public override function Result(point:b2ContactResult):void
      {
      }
      
      private var shape1Dictionary:Dictionary = new Dictionary();
   }
}
