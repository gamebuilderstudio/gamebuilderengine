/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Rendering2D
{
   import PBLabs.Engine.Entity.EntityComponent;
   import PBLabs.Engine.Core.*;
   
   import flash.geom.Point;
   import flash.geom.Rectangle;

   /**
    * Very basic spatial component that exists at a position. Velocity can be
    * applied, but no physical simulation is done.
    */ 
   public class SimpleSpatialComponent extends EntityComponent implements ITickedObject, ISpatialObject2D
   {
      public var SpatialManager:ISpatialManager2D;
      public var Rotation:Number = 0;
      public var Size:Point = null;
      
      public function get Position():Point
      {
         return _position;
      }
      
      public function set Position(value:Point):void
      {
         _position = value;
      }
      
      public function get Velocity():Point
      {
         return _velocity;
      }
      
      public function set Velocity(value:Point):void
      {
         _velocity = value;
      }
      
      public function OnTick(tickRate:Number):void
      {
         _position.x += _velocity.x * tickRate;
         _position.y += _velocity.y * tickRate;
      }
      
      public function OnInterpolateTick(factor:Number):void
      {
      }
      
      protected override function _OnAdd():void
      {
         SpatialManager.AddSpatialObject(this);
         ProcessManager.Instance.AddTickedObject(this);
      }
      
      protected override function _OnRemove():void
      {
         SpatialManager.RemoveSpatialObject(this);
         ProcessManager.Instance.RemoveTickedObject(this);
      }
      
      public function set QueryMask(v:ObjectType):void
      {
         _ObjectMask = v;
      }
      
      public function get QueryMask():ObjectType
      {
         return _ObjectMask;
      }
      
      public function get WorldExtents():Rectangle
      {
         return new Rectangle(_position.x - 25, _position.y - 25, 50, 50);         
      }

      public function CastRay(start:Point, end:Point, info:RayHitInfo):Boolean
      {
         return false;
      }
      
      private var _position:Point = new Point();
      private var _velocity:Point = new Point();
      private var _ObjectMask:ObjectType;
   }
}