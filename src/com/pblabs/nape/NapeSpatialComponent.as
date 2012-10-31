package com.pblabs.nape
{
	import com.pblabs.engine.PBUtil;
	import com.pblabs.engine.components.TickedComponent;
	import com.pblabs.engine.core.ObjectType;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.entity.EntityComponent;
	import com.pblabs.physics.IPhysics2DSpatial;
	import com.pblabs.rendering2D.DisplayObjectRenderer;
	import com.pblabs.rendering2D.IMobileSpatialObject2D;
	import com.pblabs.rendering2D.IScene2D;
	import com.pblabs.rendering2D.ISpatialManager2D;
	import com.pblabs.rendering2D.RayHitInfo;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import nape.dynamics.InteractionGroup;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Shape;
	import nape.shape.ShapeList;
	import nape.space.Space;
	
	public class NapeSpatialComponent extends TickedComponent implements IMobileSpatialObject2D, IPhysics2DSpatial
	{
		public function NapeSpatialComponent()
		{
			super();
		}
		
		private var _spriteForPointChecks : DisplayObjectRenderer;
		/**
		 * If set, a SpriteRenderComponent we can use to fulfill point occupied
		 * tests.
		 */
		[EditorData(referenceType="componentReference")]
		public function get spriteForPointChecks():DisplayObjectRenderer { return _spriteForPointChecks; }
		public function set spriteForPointChecks(value:DisplayObjectRenderer):void
		{
			if(!value) return;
			if(_spriteForPointChecks){
				size = value.size;
			}
			_spriteForPointChecks = value;
		}

		public function get bodyType():*
		{
			return _bodyType;			
		}
		
		public function set bodyType(value:*):void
		{
			_bodyType = value;
			if ( _body )
				_body.type = napeBodyType;
		}
		
		/**
		 * @inheritDoc
		 */
		[EditorData(ignore="true")]
		public function get objectMask():ObjectType
		{
			return _collidesWithTypes;
		}
		
		public function get body():Body
		{
			return _body;
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
		
		public function get position():Point
		{
			if ( _body )
				_position.setTo(_body.position.x*_spatialManager.scale, _body.position.y*_spatialManager.scale);
			return _position;
		}
		
		public function set position(value:Point):void
		{
			_position.setTo(value.x, value.y);
			if ( _body )
				_body.position.setxy(_position.x*_spatialManager.inverseScale, _position.y*_spatialManager.inverseScale);
		}
		
		public function get rotation():Number
		{
			if ( _body )
				_rotation = PBUtil.getDegreesFromRadians(_body.rotation);
			return _rotation;
		}
		
		public function set rotation(value:Number):void
		{
			_rotation = value;
			if ( body )
				body.rotation = PBUtil.getRadiansFromDegrees(_rotation);
		}
		
		public function get linearVelocity():Point
		{
			if (_body)
			{
				var scale:Number = _spatialManager.scale;
				var vel:Vec2 = _body.velocity;
				_linearVelocity.setTo(vel.x*scale, vel.y*scale);
			}
			
			return _linearVelocity;
		}
		
		public function set linearVelocity(value:Point):void
		{
			_linearVelocity = value;
			
			if (_body)
			{
				var invScale:Number = _spatialManager.inverseScale;
				_body.velocity.setxy(_linearVelocity.x*invScale, _linearVelocity.y*invScale);
			}
		}
		
		public function get angularVelocity():Number
		{
			if (_body)
			{
				var velocity:Number = _body.angularVel;
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
				_body.angularVel = velocity;
			}
		}
		
		public function get size():Point
		{
			return _size;
		}
		
		public function set size(value:Point):void
		{
			_size = value;
		}
		
		public function get autoAlign():Boolean
		{
			return _autoAlign;
		}
		
		public function set autoAlign(value:Boolean):void
		{
			_autoAlign = value;
		}
		
		public function get canMove():Boolean
		{
			return _canMove;
		}
		
		public function set canMove(value:Boolean):void
		{
			_canMove = value;
			if ( _body )
				_body.allowMovement = _canMove;
		}
		
		public function get canRotate():Boolean
		{
			return _canRotate;
		}
		
		public function set canRotate(value:Boolean):void
		{
			_canRotate = value;
			if ( _body )
				_body.allowRotation = value;
		}
		
		[EditorData(defaultValue="true")]
		public function get canSleep():Boolean
		{
			return _canSleep;
		}
		
		public function set canSleep(value:Boolean):void
		{
			_canSleep = value;
			//if (_body)
				//_body.SetSleepingAllowed(value);
		}
		
		public function get collidesContinuously():Boolean
		{
			//if (_body)
				//return _body.IsBullet();
			
			return _collidesContinuously;
		}
		
		public function set collidesContinuously(value:Boolean):void
		{
			_collidesContinuously = value;
			//if (_body)
				//_body.SetBullet(value);
		}

		[TypeHint(type="com.pblabs.nape.CollisionShape")]
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
		
		public function get worldExtents():Rectangle
		{
			return null;
		}
		
		public function get spatialManager():ISpatialManager2D
		{
			return _spatialManager;
		}
		
		public function set spatialManager(value:ISpatialManager2D):void
		{
			_spatialManager = value as NapeManagerComponent;			
		}
		
		public function castRay(start:Point, end:Point, flags:ObjectType, result:RayHitInfo):Boolean
		{
			return false;
		}
		
		public function pointOccupied(pos:Point, mask:ObjectType, scene:IScene2D):Boolean
		{
			return false;
		}
		
		public function buildCollisionShapes():void
		{
			if (!_body)
			{
				Logger.warn(this, "buildCollisionShapes", "Cannot build collision shapes prior to registration.");
				return;
			}
			
			var space:Space;
			if ( _body.space && bodyType == BodyTypeEnum.STATIC )
			{
				space = _body.space;
				_body.space = null;
			}
			
			var shapeList:ShapeList = _body.shapes;
			shapeList.foreach( function (shape:Shape):void
			{
				shape.body = null;				
			});
			
			if (_collisionShapes)
			{
				for each (var newShape:CollisionShape in _collisionShapes){
					newShape.createShape(this).body = _body;
				}
			}
			
			if ( space )
				_body.space = space;
			
			if ( autoAlign )
				_body.align();
		}
		
		override protected function onAdd():void
		{
			/*if(! _collisionShapes)
				addCollisionShape( new CircleCollisionShape() );*/
			setupBody();
		}
		
		override protected function onRemove():void
		{
			if ( _body )
			{
				_body.space = null;
				_body = null;
			}
		}
		
		private function get napeBodyType():BodyType
		{
			switch(_bodyType)
			{
				case BodyTypeEnum.DYNAMIC:
				{
					return BodyType.DYNAMIC;
				}
					
				case BodyTypeEnum.KINEMATIC:
				{
					return BodyType.KINEMATIC;
				}
					
				case BodyTypeEnum.STATIC:
				{
					return BodyType.STATIC;
				}
					
				default:
				{
					throw new Error("Unknown body type.");
					break;
				}
			}
			return null;
		}
		
		private function setupBody():void
		{
			if((_spatialManager == null) || (_spatialManager != null && _body != null)) return;
			var invScale:Number = _spatialManager.inverseScale;
			_body = new Body(napeBodyType);
			_body.position.setxy(_position.x*invScale, _position.y*invScale);
			_body.rotation = PBUtil.getRadiansFromDegrees(_rotation);
			_body.allowMovement = _canMove;
			_body.allowRotation = _canRotate;
			_body.velocity.setxy(_linearVelocity.x*invScale, _linearVelocity.y*invScale);
			_body.angularVel = PBUtil.getRadiansFromDegrees(angularVelocity);
			
			buildCollisionShapes();
			//_body.cbType = _spatialManager.bodyCallbackType;
			_body.userData.spatial = this;
			_body.space = _spatialManager.space;
		}
		
		private var _spatialManager:NapeManagerComponent;
		private var _objectMask:ObjectType;
		private var _body:Body;
		private var _bodyType:BodyTypeEnum = BodyTypeEnum.DYNAMIC;
		private var _collisionShapes:Array;
		private var _canMove:Boolean = true;
		private var _canRotate:Boolean = true;
		private var _canSleep:Boolean = true;
		private var _autoAlign:Boolean = true;
		private var _collisionType:ObjectType = null;
		private var _collidesWithTypes:ObjectType = null;
		private var _collidesContinuously:Boolean = false;
		
		protected var _linearVelocity:Point = new Point(0, 0);
		protected var _angularVelocity:Number = 0.0;
		protected var _position:Point = new Point();
		protected var _rotation:Number = 0;
		protected var _size:Point = new Point(1,1);
		
		
	}
}