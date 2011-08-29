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
    import Box2DAS.Collision.Shapes.b2MassData;
    import Box2DAS.Collision.Shapes.b2Shape;
    import Box2DAS.Common.V2;
    import Box2DAS.Common.b2Vec2;
    import Box2DAS.Dynamics.ContactEvent;
    import Box2DAS.Dynamics.b2Body;
    import Box2DAS.Dynamics.b2BodyDef;
    import Box2DAS.Dynamics.b2Fixture;
    import Box2DAS.Dynamics.b2FixtureDef;
    
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.PBUtil;
    import com.pblabs.engine.components.TickedComponent;
    import com.pblabs.engine.core.ObjectType;
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.engine.entity.EntityComponent;
    import com.pblabs.rendering2D.DisplayObjectRenderer;
    import com.pblabs.rendering2D.IMobileSpatialObject2D;
    import com.pblabs.rendering2D.IScene2D;
    import com.pblabs.rendering2D.ISpatialManager2D;
    import com.pblabs.rendering2D.ISpatialObject2D;
    import com.pblabs.rendering2D.RayHitInfo;
    
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    /**
     * Wraps a b2Body for use with a Box2DManagerComponent and integration into
     * PushButton Engine.
     * 
     * <p>Most properties map directly to actions in Box2D, so most of the time
     * your questions about this component will really be Box2D questions in
     * disguise.</p> 
     */
    public class Box2DSpatialComponent extends TickedComponent implements IMobileSpatialObject2D
    {
		/**
		 * If set, a SpriteRenderComponent we can use to fulfill point occupied
		 * tests.
		 */
		public var spriteForPointChecks:DisplayObjectRenderer;

		[EditorData(ignore="true")]
        public var onAddedCallback:Function = null;

        public function get spatialManager():ISpatialManager2D
        {
            return _manager;
        }
        
        public function set spatialManager(value:ISpatialManager2D):void
        {
            _manager = (value as Box2DManagerComponent);
			setupBody();
        }
        
        /**
         * The Box2D b2Body wrapped by this component.
         */
        public function get body():b2Body
        {
            return _body;
        }
		
		public function get bodyType():uint 
		{
			if (_body)
				return _body.GetType();
			return _bodyDef.type;
		}
				
		public function set bodyType(value:uint):void {
			_bodyDef.type = value;
				
			if (_body)
				_body.SetType(value);
		}
        
        /**
         * @inheritDoc
         */
		[EditorData(ignore="true")]
        public function get objectMask():ObjectType
        {
            return _collidesWithTypes;
        }
        
        /**
         * @inheritDoc
         */
        public function get worldExtents():Rectangle
        {
			if(spriteForPointChecks)
				return spriteForPointChecks.displayObject.getBounds(PBE.mainClass);
            
			//TODO: how far should a spatial component actually have a size?
            return new Rectangle(position.x - (size.x * 0.5), position.y - (size.y * 0.5), size.x, size.y);         
        }
        
        /**
         * Not currently implemented.
         * @inheritDoc
         */
        public function castRay(start:Point, end:Point, mask:ObjectType, info:RayHitInfo):Boolean
        {
            return false;
        }

		/**
		 * All points in our bounding box are occupied.
		 * @inheritDoc
		 */
		public function pointOccupied(pos:Point, mask:ObjectType, scene : IScene2D):Boolean
		{
			// If no sprite then we just test our bounds.
			if(!spriteForPointChecks){
				return worldExtents.containsPoint(pos);
			}
			
			// OK, so pass it over to the sprite.
			return spriteForPointChecks.pointOccupied(pos, mask);
		}
        
        public function get collisionType():ObjectType
        {
            return _collisionType;
        }
        
        public function set collisionType(value:ObjectType):void
        {
            _collisionType = value;
            
            if (_body)
                buildCollisionShapes();
        }
        
        public function get collidesWithTypes():ObjectType
        {
            return _collidesWithTypes;
        }
        
        public function set collidesWithTypes(value:ObjectType):void
        {
            _collidesWithTypes = value;
            
            if (_body)
                buildCollisionShapes();
        }
        
		public function getWorldPosition(localPosition:Point):Point {
			return new Point(position.x + localPosition.x, position.y + localPosition.y);
		}
		
        public function get position():Point
        {
            if (_body)
            {
                var pos:V2 = _body.GetPosition();
                return new Point(int(Math.round(pos.x * _manager.scale)), int(Math.round(pos.y * _manager.scale)));
            }
            
            return new Point(_bodyDef.position.x, _bodyDef.position.y);
        }
        
        public function set position(value:Point):void
        {
            var position:V2 = _bodyDef.position.v2.xy(value.x, value.y);
            if (_body)
            {
                position.multiplyN(_manager.inverseScale);
                _body.SetTransform(position, _body.GetAngle());
            }else{
				_bodyDef.position.v2 = new V2(value.x, value.y);
				//_bodyDef.position.v2.multiplyN(_manager.inverseScale);
			}
        }
        
		public function get rotation():Number
        {
            var rotation:Number = _bodyDef.angle;
            
            if (_body)
                rotation = int(Math.round(_body.GetAngle()));
            
            return PBUtil.getDegreesFromRadians(rotation);
        }
        
        public function set rotation(value:Number):void
        {
            var rotation:Number = PBUtil.getRadiansFromDegrees(value);
            _bodyDef.angle = rotation;
            
            if (_body)
                _body.SetTransform(_body.GetPosition(), rotation);
        }
        
        [EditorData(defaultValue="100|100")]
        public function get size():Point
        {
            return _size;
        }
        
        public function set size(value:Point):void
        {
			if(value.x < 1)
				value.x = 1;
			if(value.y < 1)
				value.y = 1;
            _size = value;
            
            if (_body)
                buildCollisionShapes();
        }
        
        public function get linearVelocity():Point
        {
            if (_body)
            {
                var velocity:V2 = _body.GetLinearVelocity();
                _linearVelocity.x = velocity.x * _manager.scale;
                _linearVelocity.y = velocity.y * _manager.scale;
            }
            
            return _linearVelocity;
        }
        
        public function set linearVelocity(value:Point):void
        {
            _linearVelocity = value;
            
            if (_body)
            {
                var velocity:V2 = new V2(value.x * _manager.inverseScale, value.y * _manager.inverseScale);
                _body.SetLinearVelocity(velocity);
            }
        }
        
        public function get angularVelocity():Number
        {
            if (_body)
            {
                var velocity:Number = _body.GetAngularVelocity();
                _angularVelocity = PBUtil.getDegreesFromRadians(velocity);
            }
            
            return _angularVelocity;
        }
        
        public function set angularVelocity(value:Number):void
        {
            _angularVelocity = value;
            
            if (_body)
            {
                var velocity:Number = PBUtil.getRadiansFromDegrees(value);
                _body.SetAngularVelocity(velocity);
            }
        }
        
        [EditorData(defaultValue="true")]
        public function get canMove():Boolean
        {
            return _canMove;
        }
        
        public function set canMove(value:Boolean):void
        {
            _canMove = value;
            
            if (_body)
                updateMass();
        }
        
        [EditorData(defaultValue="true")]
        public function get canRotate():Boolean
        {
            return _canRotate;
        }
        
        public function set canRotate(value:Boolean):void
        {
            _canRotate = value;
            
            if (_body)
                updateMass();
        }
        
        [EditorData(defaultValue="true")]
        public function get canSleep():Boolean
        {
            return _canSleep;
        }
        
        public function set canSleep(value:Boolean):void
        {
            _canSleep = value;
            _bodyDef.allowSleep = value;
            if (_body)
                _body.SetSleepingAllowed(value);
        }
        
        public function get collidesContinuously():Boolean
        {
            if (_body)
                return _body.IsBullet();
            
            return _bodyDef.bullet;
        }
        
        public function set collidesContinuously(value:Boolean):void
        {
            _bodyDef.bullet = value;
            if (_body)
                _body.SetBullet(value);
        }
        
        [TypeHint(type="com.pblabs.box2D.CollisionShape")]
        public function get collisionShapes():Array
        {
            return _collisionShapes;
        }
        
        public function set collisionShapes(value:Array):void
        {
            _collisionShapes = value;
            if (_body)
                buildCollisionShapes();
        }
        
        public function buildCollisionShapes():void
        {
            if (!_body)
            {
                Logger.warn(this, "buildCollisionShapes", "Cannot build collision shapes prior to registration.");
                return;
            }
            
            var shape:b2Fixture = _body.GetFixtureList();
            while (shape)
            {
                var nextShape:b2Fixture = shape.m_next;
                _body.DestroyFixture(shape);
                shape = nextShape;
            }
            
            if (_collisionShapes)
            {
                for each (var newShape:CollisionShape in _collisionShapes){
					newShape.b2FixtureRef = createFixtureInstance(_body, newShape.createShape(this))
				}
            }
            
            updateMass();
        }
		
		public function addCollisionShape(collisionShape:CollisionShape):void {
			if (!_body)
			{
				Logger.warn(this, "buildCollisionShapes", "Cannot build collision shapes prior to registration.");
				return;
			}
			if(!_collisionShapes) _collisionShapes = new Array();
			_collisionShapes.push(collisionShape);
			collisionShape.b2FixtureRef = createFixtureInstance(_body, collisionShape.createShape(this))
			updateMass();
		}
				
		public function removeCollisionShape(collisionShape:CollisionShape):void {
			var i : int = 0;
			for each (var shape:CollisionShape in _collisionShapes){
				if(shape == collisionShape){
					_collisionShapes.splice(i, 1);
				}
				i++;
			}
			_body.DestroyFixture(collisionShape.b2FixtureRef);
		}
		
        public function updateMass():void
        {
            _body.ResetMassData();
            if (!_canMove || !_canRotate)
            {
                var mass:b2MassData = new b2MassData();
                mass.center.SetV(_body.GetLocalCenter());
                if (_canMove)
                    mass.mass = _body.GetMass();
                else
                    mass.mass = 0;
                
                if (_canRotate)
                    mass.I = _body.GetInertia();
                else
                    mass.I = 0;
                
                _body.SetMassData(mass);
            }
        }
        
		/**
		 * @inheritDoc
		 */
		override public function onTick(tickRate:Number):void
		{
			position = new Point(position.x+(linearVelocity.x * tickRate), position.y+(linearVelocity.y * tickRate));
			rotation += angularVelocity * tickRate;
		}

		override protected function onAdd():void
        {
			if(! _collisionShapes)
				addCollisionShape( new CircleCollisionShape() );
			
			setupBody();

			if(!spriteForPointChecks)
				spriteForPointChecks = owner.lookupComponentByType( DisplayObjectRenderer ) as DisplayObjectRenderer;
		}
        
        override protected function onRemove():void 
        {
            _manager.removeBody(_body);
            _body = null;
        }
		
		override protected function onReset():void
		{
			super.onReset();
			
			if(spriteForPointChecks && (spriteForPointChecks.owner == null || spriteForPointChecks.owner != this.owner))
				spriteForPointChecks = null;
			
			
			if(!spriteForPointChecks)
				spriteForPointChecks = owner.lookupComponentByType( DisplayObjectRenderer) as DisplayObjectRenderer;
			
		}

		private function createFixtureInstance(body : b2Body, fixtureDef : b2FixtureDef):b2Fixture
		{
			var fixture : b2Fixture = body.CreateFixture(fixtureDef);
			fixture.m_reportBeginContact = true;
			fixture.m_reportEndContact = true;
			fixture.m_reportPostSolve = true;
			fixture.m_reportPreSolve = true;
			return fixture;
		}
		
		private function setupBody():void
		{
			if((_manager == null) || (_manager != null && _body != null)) return;
			
			_bodyDef.position.v2 = _bodyDef.position.v2.multiplyN(_manager.inverseScale);
			_manager.addBody(_bodyDef, this, 
				function(body:b2Body):void
				{
					_body = body;
					_body.SetUserData(this);
					_body.SetTransform(_bodyDef.position.v2, rotation);
					//_bodyDef.position.v2.multiplyN(_manager.scale);
					linearVelocity = _linearVelocity;
					angularVelocity = _angularVelocity;
					
					buildCollisionShapes();
					
					if (onAddedCallback != null)
						onAddedCallback(this);
				});
		}
        
        private var _collisionType:ObjectType = null;
        private var _collidesWithTypes:ObjectType = null;
        
        private var _canMove:Boolean = true;
        private var _canRotate:Boolean = true;
        
        private var _linearVelocity:Point = new Point(0, 0);
        private var _angularVelocity:Number = 0.0;
        private var _canSleep:Boolean = true;
        
        private var _collisionShapes:Array = null;
        private var _collidesContinuously:Boolean = false;
        
		protected var _manager:Box2DManagerComponent = null;
        protected var _body:b2Body = null;
		protected var _bodyDef:b2BodyDef = new b2BodyDef();
		
		protected var _size:Point = new Point(10, 10);
    }
}