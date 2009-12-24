/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is property of PushButton Labs, LLC and NOT under the MIT license.
 ******************************************************************************/
package com.pblabs.rollyGame
{
   import com.pblabs.animation.*;
   import com.pblabs.engine.PBE;
   import com.pblabs.engine.core.*;
   import com.pblabs.engine.entity.*;
   import com.pblabs.engine.resource.*;
   import com.pblabs.rendering2D.*;
   
   import flash.geom.*;

   /**
    * Class responsible for ball physics, input handling, and gameplay (ie, 
    * picking up gems).
    */
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
            _InputMap.mapActionToHandler("GoLeft", _OnLeft);
            _InputMap.mapActionToHandler("GoRight", _OnRight);
            _InputMap.mapActionToHandler("GoUp", _OnUp);
            _InputMap.mapActionToHandler("GoDown", _OnDown);
            _InputMap.mapActionToHandler("Jump", _OnJump);
         }
      }
            
      public override function onTick(tickRate:Number):void
      {
         // Sample the map for our current position.
         var n:Point = new Point();
         if(Map)
            Height = Map.getNormalAndHeight(position.x, position.y, n);
         
         // Scale the renderer.
         BallScale.x = (0.5 + Height) * 32;
         BallScale.y = (0.5 + Height) * 32;
         Radius = (0.5 + Height) * 16;
         
         // Apply velocity from slope.
         velocity.x += n.x * NormalForce;
         velocity.y += n.y * NormalForce;
         
         // Apply drag.
         velocity.x *= DragCoefficient;
         velocity.y *= DragCoefficient;
         
         // Apply movement forces.
         velocity.x += (_Right - _Left) * MoveForce;
         velocity.y += (_Down - _Up) * MoveForce;
         
         // Figure out if we need to bounce off the walls.
         if(position.x <= TrueRadius && velocity.x < 0 || position.x >= 640 - TrueRadius && velocity.x > 0)
            velocity.x = -velocity.x * 0.9;
         if(position.y <= TrueRadius && velocity.y < 0 || position.y >= 480 - TrueRadius && velocity.y > 0)
            velocity.y = -velocity.y * 0.9;
         
         // Update position.
         position = new Point( 
             position.x + velocity.x * tickRate,
             position.y + velocity.y * tickRate); 
         
         // Look for stuff to pick up.
         var results:Array = new Array();
         spatialManager.queryCircle(position, PickupRadius, PickupType, results);
         
         for(var i:int=0; i<results.length; i++)
         {
            var so:IEntityComponent = results[i] as IEntityComponent;
            so.owner.destroy();
            
            RollyBallGame.currentScore++;
            
            if(PickupSound)
               PickupSound.soundObject.play();
            
            // Spawn a new coin somewhere.
            PBE.makeEntity("Coin", 
                {
                    "@Spatial.position": new Point(20 + Math.random() * 600, 20 + Math.random() * 400) 
                });
         }
      }

      private function _HandleFirstMove():void
      {
         if(OnFirstMoveAnimation)
         {
            OnFirstMoveAnimation.play("FadeOut", 1);
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