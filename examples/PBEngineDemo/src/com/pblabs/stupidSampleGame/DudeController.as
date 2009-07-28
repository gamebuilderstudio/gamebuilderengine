/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.StupidSampleGame
{
   import com.pblabs.box2D.CollisionEvent;
   import com.pblabs.engine.core.ITickedObject;
   import com.pblabs.engine.core.InputMap;
   import com.pblabs.engine.core.ObjectTypeManager;
   import com.pblabs.engine.core.ProcessManager;
   import com.pblabs.engine.entity.EntityComponent;
   import com.pblabs.engine.entity.PropertyReference;
   import com.pblabs.engine.resource.*;
   
   import flash.geom.Point;
   import flash.media.Sound;

   public class DudeController extends EntityComponent implements ITickedObject
   {
      [TypeHint(type="flash.geom.Point")]
      public var velocityReference:PropertyReference;
      
      public function get input():InputMap
      {
         return _inputMap;
      }
      
      public function set input(value:InputMap):void
      {
         _inputMap = value;
         
         if (_inputMap != null)
         {
            _inputMap.mapActionToHandler("GoLeft", _OnLeft);
            _inputMap.mapActionToHandler("GoRight", _OnRight);
            _inputMap.mapActionToHandler("Jump", _OnJump);
         }
      }
      
      public function onTick(tickRate:Number):void
      {
         var move:Number = _right - _left;
         var velocity:Point = owner.getProperty(velocityReference);
         velocity.x = move * 100;
         
         if (_jump > 0)
         {
            if (_sound != null)
               _sound.play();
            
            velocity.y -= 200;
            _jump = 0;
         }
         
         owner.setProperty(velocityReference, velocity);
      }
      
      public function onInterpolateTick(factor:Number):void
      {
      }
      
      protected override function onAdd():void
      {
         ProcessManager.instance.addTickedObject(this);
         ResourceManager.instance.load("../Assets/Sounds/testSound.mp3", MP3Resource, _OnSoundLoaded);
         
         owner.eventDispatcher.addEventListener(CollisionEvent.COLLISION_EVENT, _OnCollision);
         owner.eventDispatcher.addEventListener(CollisionEvent.COLLISION_STOPPED_EVENT, _OnCollisionEnd);
      }
      
      protected override function onRemove():void
      {
         owner.eventDispatcher.removeEventListener(CollisionEvent.COLLISION_EVENT, _OnCollision);
         owner.eventDispatcher.removeEventListener(CollisionEvent.COLLISION_STOPPED_EVENT, _OnCollisionEnd);
         
         ResourceManager.instance.unload("../Assets/Sounds/testSound.mp3", MP3Resource);
         ProcessManager.instance.removeTickedObject(this);
      }
      
      private function _OnCollision(event:CollisionEvent):void
      {
         if (ObjectTypeManager.instance.doesTypeOverlap(event.collidee.collisionType, "Platform"))
         {
            if (event.normal.y > 0.7)
               _onGround++;
         }
         
         if (ObjectTypeManager.instance.doesTypeOverlap(event.collider.collisionType, "Platform"))
         {
            if (event.normal.y < -0.7)
               _onGround++;
         }
      }
      
      private function _OnCollisionEnd(event:CollisionEvent):void
      {
         if (ObjectTypeManager.instance.doesTypeOverlap(event.collidee.collisionType, "Platform"))
         {
            if (event.normal.y > 0.7)
               _onGround--;
         }
         
         if (ObjectTypeManager.instance.doesTypeOverlap(event.collider.collisionType, "Platform"))
         {
            if (event.normal.y < -0.7)
               _onGround--;
         }
      }
      
      private function _OnSoundLoaded(resource:MP3Resource):void
      {
         _sound = resource.soundObject;
      }
      
      private function _OnLeft(value:Number):void
      {
         _left = value;
      }
      
      private function _OnRight(value:Number):void
      {
         _right = value;
      }
      
      private function _OnJump(value:Number):void
      {
         if (_onGround > 0)
            _jump = value;
      }
      
      private var _sound:Sound = null;
      private var _inputMap:InputMap;
      private var _left:Number = 0;
      private var _right:Number = 0;
      private var _jump:Number = 0;
      private var _onGround:int = 0;
   }
}