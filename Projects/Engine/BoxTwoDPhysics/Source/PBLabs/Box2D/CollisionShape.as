/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Box2D
{
   import Box2D.Collision.Shapes.b2ShapeDef;
   
   public class CollisionShape
   {
      public function get Density():Number
      {
         return _density;
      }
      
      public function set Density(value:Number):void
      {
         _density = value;
         
         if (_parent != null)
            _parent.BuildCollisionShapes();
      }
      
      public function get Friction():Number
      {
         return _friction;
      }
      
      public function set Friction(value:Number):void
      {
         _friction = value;
         
         if (_parent != null)
            _parent.BuildCollisionShapes();
      }
      
      public function get Restitution():Number
      {
         return _restitution;
      }
      
      public function set Restitution(value:Number):void
      {
         _restitution = value;
         
         if (_parent != null)
            _parent.BuildCollisionShapes();
      }
      
      public function get IsTrigger():Boolean
      {
         return _isTrigger;
      }
      
      public function set IsTrigger(value:Boolean):void
      {
         _isTrigger = value;
         
         if (_parent != null)
            _parent.BuildCollisionShapes();
      }
      
      public function CreateShape(parent:Box2DSpatialComponent):b2ShapeDef
      {
         _parent = parent;
         
         var shape:b2ShapeDef = _CreateShape();
         shape.friction = _friction;
         shape.density = _density;
         shape.restitution = _restitution;
         shape.isSensor = _isTrigger;
         shape.userData = parent;
         
         if (parent.CollisionType != null)
            shape.filter.categoryBits = parent.CollisionType.Bits;
         
         if (parent.CollidesWithTypes != null)
            shape.filter.maskBits = parent.CollidesWithTypes.Bits;
         
         return shape;
      }
      
      protected function _CreateShape():b2ShapeDef
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