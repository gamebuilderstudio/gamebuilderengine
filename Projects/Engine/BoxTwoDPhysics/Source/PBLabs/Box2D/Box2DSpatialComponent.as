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
   import Box2D.Collision.Shapes.b2MassData;
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2BodyDef;
   
   import PBLabs.Engine.Entity.EntityComponent;
   import PBLabs.Engine.Core.ObjectType;
   import PBLabs.Engine.Debug.Logger;
   import PBLabs.Engine.Math.Utility;
   import PBLabs.Rendering2D.ISpatialObject2D;
   
   import flash.geom.Point;

   public class Box2DSpatialComponent extends EntityComponent
   {
      public function get Manager():Box2DManagerComponent
      {
         return _manager;
      }
      
      public function set Manager(value:Box2DManagerComponent):void
      {
         if (_body != null)
         {
            Logger.PrintWarning(this, "set Manager", "The manager can only be set before the component is registered.");
            return; 
         }
         
         _manager = value;
      }
      
      public function get Body():b2Body
      {
         return _body;
      }
      
      public function get CollisionType():ObjectType
      {
         return _collisionType;
      }
      
      public function set CollisionType(value:ObjectType):void
      {
         _collisionType = value;
         
         if (_body != null)
            BuildCollisionShapes();
      }
      
      public function get CollidesWithTypes():ObjectType
      {
         return _collidesWithTypes;
      }
      
      public function set CollidesWithTypes(value:ObjectType):void
      {
         _collidesWithTypes = value;
         
         if (_body != null)
            BuildCollisionShapes();
      }
      
      public function get Position():Point
      {
         if (_body != null)
         {
            var position:b2Vec2 = _body.GetPosition();
            return new Point(position.x * _manager.Scale, position.y * _manager.Scale);
         }
         
         return new Point(_bodyDef.position.x, _bodyDef.position.y);
      }
      
      public function set Position(value:Point):void
      {
         var position:b2Vec2 = new b2Vec2(value.x, value.y);
         _bodyDef.position = position;
         
         if (_body != null)
         {
            position.Multiply(_manager.InverseScale);
            _body.SetXForm(position, _body.GetAngle());
         }
      }
      
      public function get Rotation():Number
      {
         var rotation:Number = _bodyDef.angle;
         
         if (_body != null)
            rotation = _body.GetAngle();
         
         return Utility.GetDegreesFromRadians(rotation);
      }
      
      public function set Rotation(value:Number):void
      {
         var rotation:Number = Utility.GetRadiansFromDegrees(value);
         _bodyDef.angle = rotation;
         
         if (_body != null)
            _body.SetXForm(_body.GetPosition(), rotation);
      }
      
      [EditorData(defaultValue="100|100")]
      public function get Size():Point
      {
         return _size;
      }
      
      public function set Size(value:Point):void
      {
         _size = value;
         
         if (_body != null)
            BuildCollisionShapes();
      }
      
      public function get LinearVelocity():Point
      {
         if (_body != null)
         {
            var velocity:b2Vec2 = _body.GetLinearVelocity();
            _linearVelocity.x = velocity.x * _manager.Scale;
            _linearVelocity.y = velocity.y * _manager.Scale;
         }
         
         return _linearVelocity;
      }
      
      public function set LinearVelocity(value:Point):void
      {
         _linearVelocity = value;
         
         if (_body != null)
         {
            var velocity:b2Vec2 = new b2Vec2(value.x * _manager.InverseScale, value.y * _manager.InverseScale);
            _body.SetLinearVelocity(velocity);
         }
      }
      
      public function get AngularVelocity():Number
      {
         if (_body != null)
         {
            var velocity:Number = _body.GetAngularVelocity();
            _angularVelocity = Utility.GetDegreesFromRadians(velocity);
         }
         
         return _angularVelocity;
      }
      
      public function set AngularVelocity(value:Number):void
      {
         _angularVelocity = value;
         
         if (_body != null)
         {
            var velocity:Number = Utility.GetRadiansFromDegrees(value);
            _body.SetAngularVelocity(velocity);
         }
      }
      
      [EditorData(defaultValue="true")]
      public function get CanMove():Boolean
      {
         return _canMove;
      }
      
      public function set CanMove(value:Boolean):void
      {
         _canMove = value;
         
         if (_body != null)
            UpdateMass();
      }
      
      [EditorData(defaultValue="true")]
      public function get CanRotate():Boolean
      {
         return _canRotate;
      }
      
      public function set CanRotate(value:Boolean):void
      {
         _canRotate = value;
         
         if (_body != null)
            UpdateMass();
      }
      
      [EditorData(defaultValue="true")]
      public function get CanSleep():Boolean
      {
         return _canSleep;
      }
      
      public function set CanSleep(value:Boolean):void
      {
         _canSleep = value;
         _bodyDef.allowSleep = value;
         if (_body != null)
            _body.AllowSleeping(value);
      }
      
      public function get CollidesContinuously():Boolean
      {
         if (_body != null)
            return _body.IsBullet();
         
         return _bodyDef.isBullet
      }
      
      public function set CollidesContinuously(value:Boolean):void
      {
         _bodyDef.isBullet = value;
         if (_body != null)
            _body.SetBullet(value);
      }
      
      [TypeHint(type="PBLabs.Box2D.CollisionShape")]
      public function get CollisionShapes():Array
      {
         return _collisionShapes;
      }
      
      public function set CollisionShapes(value:Array):void
      {
         _collisionShapes = value;
         if (_body != null)
            BuildCollisionShapes();
      }
      
      public function BuildCollisionShapes():void
      {
         if (_body == null)
         {
            Logger.PrintWarning(this, "BuildCollisionShapes", "Cannot build collision shapes prior to registration.");
            return;
         }
         
         var shape:b2Shape = _body.GetShapeList();
         while (shape != null)
         {
            var nextShape:b2Shape = shape.m_next;
            _body.DestroyShape(shape);
            shape = nextShape;
         }
         
         if (_collisionShapes != null)
         {
            for each (var newShape:CollisionShape in _collisionShapes)
               _body.CreateShape(newShape.CreateShape(this));
         }
         
         UpdateMass();
      }
      
      public function UpdateMass():void
      {
         _body.SetMassFromShapes();
         if (!_canMove || !_canRotate)
         {
            var mass:b2MassData = new b2MassData();
            mass.center = _body.GetLocalCenter();
            if (_canMove)
               mass.mass = _body.GetMass();
            else
               mass.mass = 0;
            
            if (_canRotate)
               mass.I = _body.GetInertia();
            else
               mass.I = 0;
            
            _body.SetMass(mass);
         }
      }
      
      protected override function _OnAdd():void
      {
         if (_manager == null)
         {
            Logger.PrintWarning(this, "_OnAdd", "A Box2DSpatialComponent cannot be registered without a manager.");
            return;
         }
         
         _bodyDef.position.Multiply(_manager.InverseScale);
         _body = _manager.Add(_bodyDef);
         _body.SetUserData(this);
         _bodyDef.position.Multiply(_manager.Scale);
         
         LinearVelocity = _linearVelocity;
         AngularVelocity = _angularVelocity;
         
         BuildCollisionShapes();
      }
      
      protected override function _OnRemove():void 
      {
         _manager.Remove(_body);
         _body = null;
      }
      
      private var _manager:Box2DManagerComponent = null;
      private var _collisionType:ObjectType = null;
      private var _collidesWithTypes:ObjectType = null;
      
      private var _size:Point = new Point(10, 10);
      
      private var _canMove:Boolean = true;
      private var _canRotate:Boolean = true;
      
      private var _linearVelocity:Point = new Point(0, 0);
      private var _angularVelocity:Number = 0.0;
      private var _canSleep:Boolean = true;
      
      private var _collisionShapes:Array = null;
      private var _collidesContinuously:Boolean = false;
      
      private var _body:b2Body = null;
      private var _bodyDef:b2BodyDef = new b2BodyDef();
   }
}