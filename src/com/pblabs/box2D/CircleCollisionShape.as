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
   import Box2D.Collision.Shapes.b2CircleDef;
   import Box2D.Collision.Shapes.b2ShapeDef;
   import Box2D.Common.Math.b2Vec2;
   
   import flash.geom.Point;
   
   public class CircleCollisionShape extends CollisionShape
   {
      [EditorData(defaultValue="1")]
      public function get Radius():Number
      {
         return _radius;
      }
      
      public function set Radius(value:Number):void
      {
         _radius = value;
         
         if (_parent != null)
            _parent.BuildCollisionShapes();
      }
      
      public function get Offset():Point
      {
         return _offset;
      }
      
      public function set Offset(value:Point):void
      {
         _offset = value;
         
         if (_parent != null)
            _parent.BuildCollisionShapes();
      }
      
      protected override function _CreateShape():b2ShapeDef
      {
         var halfSize:Point = new Point(_parent.Size.x * 0.5, _parent.Size.y * 0.5);
         var scale:Number = _parent.Manager.InverseScale;
         
         var shape:b2CircleDef = new b2CircleDef();
         
         shape.radius = _radius * scale * (halfSize.x > halfSize.y ? halfSize.x : halfSize.y);
         shape.localPosition = new b2Vec2(_offset.x, _offset.y);
         
         return shape;
      }
      
      private var _radius:Number = 1.0;
      private var _offset:Point = new Point(0, 0);
   }
}