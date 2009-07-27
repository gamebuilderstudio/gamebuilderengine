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
   import Box2D.Collision.Shapes.b2ShapeDef;
   
   [EditorData(ignore="true")]
   public class CollisionShape
   {
      [EditorData(defaultValue="1")]
      public function get density():Number
      {
         return _density;
      }
      
      public function set density(value:Number):void
      {
         _density = value;
         
         if (_parent)
            _parent.buildCollisionShapes();
      }
      
      public function get friction():Number
      {
         return _friction;
      }
      
      public function set friction(value:Number):void
      {
         _friction = value;
         
         if (_parent)
            _parent.buildCollisionShapes();
      }
      
      public function get restitution():Number
      {
         return _restitution;
      }
      
      public function set restitution(value:Number):void
      {
         _restitution = value;
         
         if (_parent)
            _parent.buildCollisionShapes();
      }
      
      public function get isTrigger():Boolean
      {
         return _isTrigger;
      }
      
      public function set isTrigger(value:Boolean):void
      {
         _isTrigger = value;
         
         if (_parent)
            _parent.buildCollisionShapes();
      }
      
      public function createShape(parent:Box2DSpatialComponent):b2ShapeDef
      {
         _parent = parent;
         
         var shape:b2ShapeDef = doCreateShape();
         shape.friction = _friction;
         shape.density = _density;
         shape.restitution = _restitution;
         shape.isSensor = _isTrigger;
         shape.userData = parent;
         
         if (parent.collisionType)
            shape.filter.categoryBits = parent.collisionType.bits;
         
         if (parent.collidesWithTypes)
            shape.filter.maskBits = parent.collidesWithTypes.bits;
         
         return shape;
      }
      
      protected function doCreateShape():b2ShapeDef
      {
         return new b2ShapeDef();
      }
      
      protected var _parent:Box2DSpatialComponent = null;
      
      private var _isTrigger:Boolean = false;
      private var _density:Number = 1.0;
      private var _friction:Number = 0.0;
      private var _restitution:Number = 0.0;
   }
}