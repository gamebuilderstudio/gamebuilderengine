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
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Dynamics.b2ContactFilter;

   public class ContactFilter extends b2ContactFilter
   {
      override public function ShouldCollide(shape1:b2Shape, shape2:b2Shape):Boolean
      {
         if (!super.ShouldCollide(shape1, shape2))
            return false;
         
         return true;
      }
   }
}