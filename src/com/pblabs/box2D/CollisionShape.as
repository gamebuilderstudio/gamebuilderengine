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
	import Box2DAS.Dynamics.b2Fixture;
	import Box2DAS.Dynamics.b2FixtureDef;
	
	import flash.geom.Point;

   [EditorData(ignore="true")]
   public class CollisionShape
   {
	  private var _b2FixtureRef : b2Fixture
	  [EditorData(ignore="true")]
	  public function get b2FixtureRef():b2Fixture { return _b2FixtureRef; }
	  public function set b2FixtureRef(obj : b2Fixture):void { 
		  _b2FixtureRef = obj; 
	  }
	  
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
      
	  /**
	  * Used to scale the vertices or radius of a CollisionShape during shape creation
	  * without affecting the original values
	  **/
	  public function get shapeScale():Point
	  {
		  //TODO: Remove, Its temporary until underlying Box2D engine is switched to AS3 version. 
		  //Alchemy version blows up with values of 0
		  if(_shapeScale.x <= 0) _shapeScale.x = .2;
		  if(_shapeScale.y <= 0) _shapeScale.y = .2;
		  return _shapeScale;
	  }
	  
	  public function set shapeScale(value:Point):void
	  {
		  _shapeScale = value;
		  
		  if (_parent)
			  _parent.buildCollisionShapes();
	  }

	  public function createShape(parent:Box2DSpatialComponent):b2FixtureDef
      {
         _parent = parent;
         
         var shape:b2FixtureDef = doCreateShape();
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
      
      protected function doCreateShape():b2FixtureDef
      {
         return new b2FixtureDef();
      }
      
      protected var _parent:Box2DSpatialComponent = null;
      
      private var _isTrigger:Boolean = false;
      private var _density:Number = 1.0;
      private var _friction:Number = 0.0;
      private var _restitution:Number = 0.0;
	  private var _shapeScale : Point = new Point(1,1);
   }
}