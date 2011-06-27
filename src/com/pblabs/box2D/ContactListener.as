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
   import Box2DAS.Collision.b2ContactPoint;
   import Box2DAS.Collision.b2Manifold;
   import Box2DAS.Dynamics.*;
   import Box2DAS.Dynamics.Contacts.*;
   
   import flash.utils.Dictionary;

   public class ContactListener extends b2ContactListener
   {
	  override public function BeginContact(contact:b2Contact):void
      {
		 var spatial1:Box2DSpatialComponent = contact.GetFixtureA().GetUserData() as Box2DSpatialComponent;
		 var spatial2:Box2DSpatialComponent = contact.GetFixtureB().GetUserData() as Box2DSpatialComponent;
        
         if (!shape1Dictionary[spatial1])
            shape1Dictionary[spatial1] = 0;
         
         if (!shape1Dictionary[spatial2])
            shape1Dictionary[spatial2] = 0;

         //check for existence of both owners because one might be destroyed during the event.
         if (spatial1.owner) 
			spatial1.owner.eventDispatcher.dispatchEvent(new CollisionEvent(CollisionEvent.COLLISION_EVENT, contact));
         
         if (spatial2.owner)
			spatial2.owner.eventDispatcher.dispatchEvent(new CollisionEvent(CollisionEvent.COLLISION_EVENT, contact));
         
         shape1Dictionary[spatial1]++;
         shape1Dictionary[spatial2]++;
      }
	  
	  override public function PreSolve(contact:b2Contact, oldManifold:b2Manifold):void 
	  {
  			var spatial1:Box2DSpatialComponent = contact.GetFixtureA().GetUserData() as Box2DSpatialComponent;
  			var spatial2:Box2DSpatialComponent = contact.GetFixtureB().GetUserData() as Box2DSpatialComponent;
  			//check for existence of both owners because one might be destroyed during the event.
  			if (spatial1.owner) 
	  			spatial1.owner.eventDispatcher.dispatchEvent(new CollisionEvent(CollisionEvent.PRE_COLLISION_EVENT, contact));
  
  			if (spatial2.owner)
	  			spatial2.owner.eventDispatcher.dispatchEvent(new CollisionEvent(CollisionEvent.PRE_COLLISION_EVENT, contact));
	  }
      
	  override public function EndContact(contact:b2Contact):void
      {
		  var spatial1:Box2DSpatialComponent = contact.GetFixtureA().GetUserData() as Box2DSpatialComponent;
		  var spatial2:Box2DSpatialComponent = contact.GetFixtureB().GetUserData() as Box2DSpatialComponent;
         
         shape1Dictionary[spatial1]--;
         shape1Dictionary[spatial2]--;

		 //check for existence of both owners because one might be destroyed during the event.
		 if (spatial1.owner) 
			 spatial1.owner.eventDispatcher.dispatchEvent(new CollisionEvent(CollisionEvent.COLLISION_STOPPED_EVENT, contact));
		 
		 if (spatial2.owner)
			 spatial2.owner.eventDispatcher.dispatchEvent(new CollisionEvent(CollisionEvent.COLLISION_STOPPED_EVENT, contact));
      }
      
      private var shape1Dictionary:Dictionary = new Dictionary();
   }
}
