/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is property of PushButton Labs, LLC and NOT under the MIT license.
 ******************************************************************************/
package PBLabs.RollyGame
{
   import PBLabs.Rendering2D.*;
   import PBLabs.Animation.*;
   import PBLabs.Engine.Core.*;
   import PBLabs.Engine.Entity.*;
   import PBLabs.Engine.Resource.*;
   import flash.geom.*;
   import mx.controls.*;

   public class BallMover extends SimpleSpatialComponent
   {
      public var Map:NormalMap;
      public var Height:Number = 1.0;
      public var Radius:Number = 16;
      public var TrueRadius:Number = 16;
      public var BallScale:Point = new Point(1,1);
      public var MoveForce:Number = 12;
      public var NormalForce:Number = 35;
      public var DragCoefficient:Number = 0.95;
      public var PickupType:ObjectType = new ObjectType();
      public var PickupRadius:Number = 4;
      
      public var OnFirstMoveAnimation:AnimatorComponent = null;
      public var PickupSound:MP3Resource;

      public function get Input():InputMap
      {
         return _InputMap;
      }
      
      public function set Input(value:InputMap):void
      {
         _InputMap = value;
         
         if (_InputMap != null)
         {
            _InputMap.MapActionToHandler("GoLeft", _OnLeft);
            _InputMap.MapActionToHandler("GoRight", _OnRight);
            _InputMap.MapActionToHandler("GoUp", _OnUp);
            _InputMap.MapActionToHandler("GoDown", _OnDown);
            _InputMap.MapActionToHandler("Jump", _OnJump);
         }
      }
            
      public override function OnTick(tickRate:Number):void
      {
         // Sample the map for our current position.
         var n:Point = new Point();
         if(Map)
            Height = Map.GetNormalAndHeight(Position.x, Position.y, n);
         
         // Scale the renderer.
         BallScale.x = (0.5 + Height) * 32;
         BallScale.y = (0.5 + Height) * 32;
         Radius = (0.5 + Height) * 16;
         
         // Apply velocity from slope.
         Velocity.x += n.x * NormalForce;
         Velocity.y += n.y * NormalForce;
         
         //trace(n.toString());
         
         // Apply drag.
         Velocity.x *= DragCoefficient;
         Velocity.y *= DragCoefficient;
         
         // Apply movement forces.
         Velocity.x += (_Right - _Left) * MoveForce;
         Velocity.y += (_Down - _Up) * MoveForce;
         
         // Figure out if we need to bounce off the walls.
         if(Position.x <= TrueRadius && Velocity.x < 0 || Position.x >= 640 - TrueRadius && Velocity.x > 0)
            Velocity.x = -Velocity.x * 0.9;
         if(Position.y <= TrueRadius && Velocity.y < 0 || Position.y >= 480 - TrueRadius && Velocity.y > 0)
            Velocity.y = -Velocity.y * 0.9;
         
         // Update position.
         Position.x += Velocity.x * tickRate;
         Position.y += Velocity.y * tickRate;
         
         // Look for stuff to pick up.
         var results:Array = new Array();
         SpatialManager.QueryCircle(Position, PickupRadius, PickupType, results);
         
         for(var i:int=0; i<results.length; i++)
         {
            var so:IEntityComponent = results[i] as IEntityComponent;
            so.Owner.Destroy();
            
            (Global.MainClass as Object).AddPoints(1);
            
            if(PickupSound)
               PickupSound.SoundObject.play();
            
            // Spawn a new coin somewhere.
            var coinEntity:IEntity = TemplateManager.Instance.InstantiateEntity("Coin");
            coinEntity.SetProperty(new PropertyReference("@Spatial.Position"), new Point(20 + Math.random() * 600, 20 + Math.random() * 400)); 
         }
      }

      private function _HandleFirstMove():void
      {
         if(OnFirstMoveAnimation)
         {
            OnFirstMoveAnimation.Play("FadeOut", 1);
            OnFirstMoveAnimation = null;
         }
      }

      private function _OnLeft(value:Number):void
      {
         _HandleFirstMove();
         _Left = value;
      }

      private function _OnRight(value:Number):void
      {
         _HandleFirstMove();
         _Right = value;
      }

      private function _OnUp(value:Number):void
      {
         _HandleFirstMove();
         _Up = value;
      }

      private function _OnDown(value:Number):void
      {
         _HandleFirstMove();
         _Down = value;
      }

      private function _OnJump(value:Number):void
      {
         _HandleFirstMove();
         _Jump = value;
      }

      private var _InputMap:InputMap;
      private var _Left:Number = 0;
      private var _Right:Number = 0;
      private var _Up:Number = 0;
      private var _Down:Number = 0;
      private var _Jump:Number = 0;
   }
}