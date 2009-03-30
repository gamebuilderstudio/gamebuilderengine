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
      /**
       * The spatial manager this object belongs to.
       */
      public var SpatialManager:ISpatialManager2D;
      
      /**
       * The position of the object.
       */
      public var Position:Point = new Point(0, 0);
      
      /**
       * The rotation of the object.
       */
      public var Rotation:Number = 0;
      
      /**
       * The size of the object.
       */
      public var Size:Point = new Point(100, 100);
      
      /**
       * The linear velocity of the object in world units per second.
       */
      public var Velocity:Point = new Point(0, 0);
      
      /**
       * @inheritDoc
       */
      public function OnTick(tickRate:Number):void
      {
         Position.x += Velocity.x * tickRate;
         Position.y += Velocity.y * tickRate;
      }
      
      /**
       * @inheritDoc
       */
      public function OnInterpolateTick(factor:Number):void
      {
      }
      
      /**
       * @inheritDoc
       */
      protected override function _OnAdd():void
      {
         SpatialManager.AddSpatialObject(this);
         ProcessManager.Instance.AddTickedObject(this);
      }
      
      /**
       * @inheritDoc
       */
      protected override function _OnRemove():void
      {
         SpatialManager.RemoveSpatialObject(this);
         ProcessManager.Instance.RemoveTickedObject(this);
      }
      
      /**
       * @inheritDoc
       */
      public function get QueryMask():ObjectType
      {
         return _objectType;
      }
      
      /**
       * @private
       */
      public function set QueryMask(value:ObjectType):void
      {
         _objectType = value;
      }
      
      /**
       * @inheritDoc
       */
      public function get WorldExtents():Rectangle
      {
         return new Rectangle(Position.x - (Size.x * 0.5), Position.y - (Size.y * 0.5), Size.x, Size.y);         
      }
      
      /**
       * Not currently implemented.
       * @inheritDoc
       */
      public function CastRay(start:Point, end:Point, info:RayHitInfo):Boolean
      {
         return false;
      }
      
      private var _objectType:ObjectType;
   }
}