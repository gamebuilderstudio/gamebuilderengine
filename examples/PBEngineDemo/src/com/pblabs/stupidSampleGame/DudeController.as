/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.stupidSampleGame
{
    import com.pblabs.box2D.CollisionEvent;
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.components.TickedComponent;
    import com.pblabs.engine.core.InputMap;
    import com.pblabs.engine.entity.EntityComponent;
    import com.pblabs.engine.entity.PropertyReference;
    
    import flash.geom.Point;
    
    /**
     * Component responsible for translating keyboard input to forces on the
     * player entity.
     */
    public class DudeController extends TickedComponent
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
        
        public override function onTick(tickRate:Number):void
        {
            var move:Number = _right - _left;
            var velocity:Point = owner.getProperty(velocityReference);
            velocity.x = move * 100;
            
            if (_jump > 0)
            {
                PBE.soundManager.play("../Assets/Sounds/testSound.mp3");
                
                velocity.y -= 200;
                _jump = 0;
            }
            
            owner.setProperty(velocityReference, velocity);
        }
        
        protected override function onAdd():void
        {
            super.onAdd();

            owner.eventDispatcher.addEventListener(CollisionEvent.COLLISION_EVENT, _OnCollision);
            owner.eventDispatcher.addEventListener(CollisionEvent.COLLISION_STOPPED_EVENT, _OnCollisionEnd);
        }
        
        protected override function onRemove():void
        {
            super.onRemove();
            
            owner.eventDispatcher.removeEventListener(CollisionEvent.COLLISION_EVENT, _OnCollision);
            owner.eventDispatcher.removeEventListener(CollisionEvent.COLLISION_STOPPED_EVENT, _OnCollisionEnd);
        }
        
        private function _OnCollision(event:CollisionEvent):void
        {
            if (PBE.objectTypeManager.doesTypeOverlap(event.collidee.collisionType, "Platform"))
            {
                if (event.normal.y > 0.7)
                    _onGround++;
            }
            
            if (PBE.objectTypeManager.doesTypeOverlap(event.collider.collisionType, "Platform"))
            {
                if (event.normal.y < -0.7)
                    _onGround++;
            }
        }
        
        private function _OnCollisionEnd(event:CollisionEvent):void
        {
            if (PBE.objectTypeManager.doesTypeOverlap(event.collidee.collisionType, "Platform"))
            {
                if (event.normal.y > 0.7)
                    _onGround--;
            }
            
            if (PBE.objectTypeManager.doesTypeOverlap(event.collider.collisionType, "Platform"))
            {
                if (event.normal.y < -0.7)
                    _onGround--;
            }
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

        private var _inputMap:InputMap;
        private var _left:Number = 0;
        private var _right:Number = 0;
        private var _jump:Number = 0;
        private var _onGround:int = 0;
    }
}