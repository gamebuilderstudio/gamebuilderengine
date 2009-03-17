package PBLabs.StupidSampleGame
{
   import PBLabs.Box2D.CollisionEvent;
   import PBLabs.Engine.Core.ITickedObject;
   import PBLabs.Engine.Core.InputMap;
   import PBLabs.Engine.Core.ObjectTypeManager;
   import PBLabs.Engine.Core.ProcessManager;
   import PBLabs.Engine.Entity.EntityComponent;
   import PBLabs.Engine.Entity.PropertyReference;
   import PBLabs.Engine.Resource.ResourceManager;
   import PBLabs.MP3Sound.MP3Resource;
   
   import flash.geom.Point;
   import flash.media.Sound;

   public class DudeController extends EntityComponent implements ITickedObject
   {
      public var VelocityReference:PropertyReference;
      
      public function get Input():InputMap
      {
         return _inputMap;
      }
      
      public function set Input(value:InputMap):void
      {
         _inputMap = value;
         
         if (_inputMap != null)
         {
            _inputMap.AddBinding("GoLeft", _OnLeft);
            _inputMap.AddBinding("GoRight", _OnRight);
            _inputMap.AddBinding("Jump", _OnJump);
         }
      }
      
      public function OnTick(tickRate:Number):void
      {
         var move:Number = _right - _left;
         var velocity:Point = Owner.GetProperty(VelocityReference);
         velocity.x = move * 100;
         
         if (_jump > 0)
         {
            if (_sound != null)
               _sound.play();
            
            velocity.y -= 200;
            _jump = 0;
         }
         
         Owner.SetProperty(VelocityReference, velocity);
      }
      
      public function OnInterpolateTick(factor:Number):void
      {
      }
      
      protected override function _OnAdd():void
      {
         ProcessManager.Instance.AddTickedObject(this);
         ResourceManager.Instance.Load("../Assets/Sounds/testSound.mp3", MP3Resource, _OnSoundLoaded);
         
         Owner.EventDispatcher.addEventListener(CollisionEvent.COLLISION_EVENT, _OnCollision);
         Owner.EventDispatcher.addEventListener(CollisionEvent.COLLISION_STOPPED_EVENT, _OnCollisionEnd);
      }
      
      protected override function _OnRemove():void
      {
         Owner.EventDispatcher.removeEventListener(CollisionEvent.COLLISION_EVENT, _OnCollision);
         Owner.EventDispatcher.removeEventListener(CollisionEvent.COLLISION_STOPPED_EVENT, _OnCollisionEnd);
         
         ResourceManager.Instance.Unload("../Assets/Sounds/testSound.mp3");
         ProcessManager.Instance.RemoveTickedObject(this);
      }
      
      private function _OnCollision(event:CollisionEvent):void
      {
         if (ObjectTypeManager.Instance.DoesTypeOverlap(event.Collidee.CollisionType, "Platform"))
         {
            if (event.Normal.y > 0.7)
               _onGround++;
         }
         
         if (ObjectTypeManager.Instance.DoesTypeOverlap(event.Collider.CollisionType, "Platform"))
         {
            if (event.Normal.y < -0.7)
               _onGround++;
         }
      }
      
      private function _OnCollisionEnd(event:CollisionEvent):void
      {
         if (ObjectTypeManager.Instance.DoesTypeOverlap(event.Collidee.CollisionType, "Platform"))
         {
            if (event.Normal.y > 0.7)
               _onGround--;
         }
         
         if (ObjectTypeManager.Instance.DoesTypeOverlap(event.Collider.CollisionType, "Platform"))
         {
            if (event.Normal.y < -0.7)
               _onGround--;
         }
      }
      
      private function _OnSoundLoaded(resource:MP3Resource):void
      {
         _sound = resource.SoundObject;
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