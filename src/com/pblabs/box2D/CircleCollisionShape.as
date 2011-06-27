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
   import Box2DAS.Collision.Shapes.*;
   import Box2DAS.Common.V2;
   import Box2DAS.Common.b2Vec2;
   import Box2DAS.Dynamics.b2FixtureDef;
   
   import flash.geom.Point;
   
   public class CircleCollisionShape extends CollisionShape
   {
      [EditorData(defaultValue="1")]
      public function get radius():Number
      {
         return _radius;
      }
      
      public function set radius(value:Number):void
      {
         _radius = value;
         
         if (_parent)
            _parent.buildCollisionShapes();
      }
      
      public function get offset():Point
      {
         return _offset;
      }
      
      public function set offset(value:Point):void
      {
         _offset = value;
         
         if (_parent)
            _parent.buildCollisionShapes();
      }
      
      override protected function doCreateShape():b2FixtureDef
      {
         var halfSize:Point = new Point(_parent.size.x * 0.5, _parent.size.y * 0.5);
         var scale:Number = (_parent.spatialManager as Box2DManagerComponent).inverseScale;
         
		 var fixture: b2FixtureDef = super.doCreateShape();
		 var shape:b2CircleShape = new b2CircleShape();
		 shape.m_radius = _radius * scale;
		 fixture.shape = shape;
         
         return fixture;
      }
      
      private var _radius:Number = 1.0;
      private var _offset:Point = new Point(0, 0);
   }
}