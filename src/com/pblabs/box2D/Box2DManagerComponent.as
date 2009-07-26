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
   import Box2D.Collision.b2AABB;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.*;
   
   import com.pblabs.engine.entity.EntityComponent;
   import com.pblabs.engine.core.*;
   import com.pblabs.engine.debug.Logger;
   import com.pblabs.rendering2D.*;
   
   import flash.geom.*;
   
   public class Box2DManagerComponent extends EntityComponent implements ITickedObject, ISpatialManager2D
   {
      [EditorData(defaultValue="30")]
      public function get Scale():Number
      {
         return _scale;
      }
      
      public function set Scale(value:Number):void
      {
         _scale = value;
      }
      
      public function get InverseScale():Number
      {
         return 1 / _scale;
      }
      
      [EditorData(defaultValue="true")]
      public function get AllowSleep():Boolean
      {
         return _allowSleep;
      }
      
      public function set AllowSleep(value:Boolean):void
      {
         if (_world)
         {
            Logger.PrintWarning(this, "AllowSleep", "This property cannot be changed once the world has been created!");
            return;
         }
         
         _allowSleep = value;
      }
      
      [EditorData(defaultValue="9.81")]
      public function get Gravity():Point
      {
         return _gravity;
      }
      
      public function set Gravity(value:Point):void
      {
         _gravity = value;
         
         if (_world)
            _world.SetGravity(new b2Vec2(value.x, value.y));
      }
      
      [EditorData(defaultValue="-10000|-10000|20000|20000")]
      public function get WorldBounds():Rectangle
      {
         return _worldBounds;
      }
      
      public function set WorldBounds(value:Rectangle):void
      {
         if (_world)
         {
            Logger.PrintWarning(this, "WorldBounds", "This property cannot be changed once the world has been created!");
            return;
         }
         
         _worldBounds = value;
      }
      
      protected override function _OnAdd():void
      {
         ProcessManager.Instance.AddTickedObject(this);
         _CreateWorld();
      }
      
      protected override function _OnRemove():void 
      {
         var body:b2Body = _world.GetBodyList();
         while (body)
         {
            var next:b2Body = body.GetNext();
            _world.DestroyBody(body);
            body = next;
         }
         
         _world = null;
         ProcessManager.Instance.RemoveTickedObject(this);
      }
      
      public function Add(bodyDef:b2BodyDef):b2Body
      {
         var body:b2Body = _world.CreateBody(bodyDef);
         return body;
      }
      
      public function Remove(body:b2Body):void
      {
         if (_world)
            _world.DestroyBody(body);
      }
      
      public function SetDebugDrawer(drawer:b2DebugDraw):void
      {
         drawer.m_drawScale = _scale;
         _world.SetDebugDraw(drawer);
      }
      
      public function OnTick(tickRate:Number):void
      {
         _world.Step(tickRate, 10);
      }
      
      public function OnInterpolateTick(factor:Number):void
      {
      }
      
      public function AddSpatialObject(object:ISpatialObject2D):void
      {
         _otherItems.AddSpatialObject(object);
      }
      
      public function RemoveSpatialObject(object:ISpatialObject2D):void
      {
         _otherItems.RemoveSpatialObject(object);
      }

      public function QueryRectangle(box:Rectangle, mask:ObjectType, results:Array):Boolean
      {
         // Query Box2D.
         var aabb:b2AABB = new b2AABB();
         aabb.lowerBound = b2Vec2.Make(box.topLeft.x / Scale, box.topLeft.y / Scale);
         aabb.upperBound = b2Vec2.Make(box.bottomRight.x / Scale, box.bottomRight.y / Scale);
         
         var resultShapes:Array = new Array(1024);
         if(_world.Query(aabb, resultShapes, 1024)==0)
            return false;
         
         // Now get the owning components back from the results and give to user.
         for(var i:int=0; i<1024; i++)
         {
            if(!resultShapes[i])
               break;
            
            var curShape:b2Shape = resultShapes[i] as b2Shape;
            var curComponent:Box2DSpatialComponent = curShape.GetBody().GetUserData() as Box2DSpatialComponent;
            if(ObjectTypeManager.Instance.DoTypesOverlap(curComponent.CollisionType, mask))
               results.push(curComponent);
         }
         
         // Let the other items have a turn.
         i += _otherItems.QueryRectangle(box, mask, results) ? 1 : 0;
         
         // If we made it anywhere with i, then we got a result.
         return (i != 0);
      }
      
      public function QueryCircle(center:Point, radius:Number, mask:ObjectType, results:Array):Boolean
      {
         return _otherItems.QueryCircle(center, radius, mask, results);
      }
      
      public function CastRay(start:Point, end:Point, mask:ObjectType, result:RayHitInfo):Boolean
      {
         return _otherItems.CastRay(start, end, mask, result);
      }
      
      /**
       * @inheritDoc
       */
      public function ObjectsUnderPoint(point:Point, mask:ObjectType, results:Array, scene:IDrawManager2D):Boolean
      {
         var tmpResults:Array = new Array();
         
         // First use the normal spatial query...
         if(!QueryCircle(point, 0.01, mask, tmpResults))
            return false;
         
         // Ok, now pass control to the objects and see what they think.
         var hitAny:Boolean = false;
         for each(var tmp:ISpatialObject2D in tmpResults)
         {
            if(!tmp.PointOccupied(point, scene))
               continue;
            
            results.push(tmp);
            hitAny = true;
         }
         
         return hitAny;
      }
      
      private function _CreateWorld():void
      {
         var bounds:b2AABB = new b2AABB();
         bounds.lowerBound.Set(_worldBounds.x / _scale, _worldBounds.y / _scale);
         bounds.upperBound.Set((_worldBounds.x + _worldBounds.width) / _scale, (_worldBounds.y + _worldBounds.height) / _scale);
         _world = new b2World(bounds, new b2Vec2(_gravity.x, _gravity.y), _allowSleep);
         _world.SetContactFilter(new ContactFilter());
         _world.SetContactListener(new ContactListener());
      }
      
      // Used to store other world objects that aren't implemented by Box2D.
      private var _otherItems:BasicSpatialManager2D = new BasicSpatialManager2D();      
      private var _scale:Number = 30;
      private var _world:b2World = null;
      private var _allowSleep:Boolean = true;
      private var _worldBounds:Rectangle = new Rectangle(-5000, -5000, 10000, 10000);
      private var _gravity:Point = new Point(0, 9.81);
   }
}