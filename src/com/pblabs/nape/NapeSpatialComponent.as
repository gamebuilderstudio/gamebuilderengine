package com.pblabs.nape
{
	import com.pblabs.engine.PBE;
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
	import com.pblabs.rendering2D.ISpatialObject2D;
	import com.pblabs.rendering2D.RayHitInfo;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import nape.dynamics.InteractionFilter;
	import nape.dynamics.InteractionGroup;
	import nape.geom.Ray;
	import nape.geom.RayResult;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyList;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Polygon;
	import nape.shape.Shape;
	import nape.shape.ShapeList;
	import nape.space.Space;
	import nape.util.ShapeDebug;
	
	public class NapeSpatialComponent extends TickedComponent implements INape2DSpatialComponent
	{
		public function NapeSpatialComponent()
		{
			super();
		}
		
		private var _debugDisplayEnabled : Boolean = true;
		public function get debugDisplayEnabled():Boolean { return _debugDisplayEnabled; }
		public function set debugDisplayEnabled(value:Boolean):void
		{
			if(_debugDisplayEnabled && !value && _shapeDebug)
			{
				if(PBE.mainStage.contains(_shapeDebug.display))
					PBE.mainStage.removeChild( _shapeDebug.display );
			}
			_debugDisplayEnabled = value;
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

		[TypeHint(type="com.pblabs.nape.BodyTypeEnum")]
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
			_interactionFilter.collisionGroup = _collisionType ? _collisionType.bits : 1;
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
			_interactionFilter.collisionMask = collidesWithTypes ? collidesWithTypes.bits : -1;
			if (_body)
				buildCollisionShapes();
		}
		
		public function get position():Point
		{
			if ( _body ){
				_body.position.toPoint(_position);
				var _scale : Number = _spatialManager.scale;
				_position.setTo(_position.x*_scale, _position.y*_scale);
			}
			return _position;
		}
		
		public function set position(value:Point):void
		{
			_position.setTo(value.x, value.y);
			if ( _body )
				_body.position.setxy(_position.x*_spatialManager.inverseScale, _position.y*_spatialManager.inverseScale);
			
			if(_shapeDebug && _body)
				_shapeDebug.transform.transform(_body.position.copy(true));
		}
		
		public function get rotation():Number
		{
			if ( _body )
				_rotation = PBUtil.getDegreesFromRadians(_body.rotation) % 360;
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
				_body.velocity.toPoint(_linearVelocity);
				_linearVelocity.setTo(_linearVelocity.x*scale, _linearVelocity.y*scale);
			}
			
			return _linearVelocity;
		}
		
		public function set linearVelocity(value:Point):void
		{
			_linearVelocity = value;
			
			if (_body)
			{
				var invScale:Number = _spatialManager.inverseScale;
				_body.velocity.setxy(_linearVelocity.x*_spatialManager.inverseScale, _linearVelocity.y*_spatialManager.inverseScale);
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
			if(_body)
				return _body.isBullet;
			
			return _collidesContinuously;
		}
		
		public function set collidesContinuously(value:Boolean):void
		{
			_collidesContinuously = value;
			if(_body)
				_body.isBullet = value;
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
			if(spriteForPointChecks && spriteForPointChecks.displayObject)
				return spriteForPointChecks.sceneBounds;
			
			return new Rectangle(position.x - (size.x * 0.5), position.y - (size.y * 0.5), size.x, size.y);         
		}
		
		public function get spatialManager():ISpatialManager2D
		{
			return _spatialManager;
		}
		
		public function set spatialManager(value:ISpatialManager2D):void
		{
			if (!isRegistered)
			{
				_spatialManager = value as NapeManagerComponent;
				return;
			}
			
			if (_spatialManager){
				destroyBody();
			}
			
			_spatialManager = value as NapeManagerComponent;
			debugDisplayEnabled = (_spatialManager && _spatialManager.visualDebugging) ? false : true;
			setupBody();
		}
		
		private var _interactionFilter : InteractionFilter = new InteractionFilter();
		public function get interactionFilter():InteractionFilter
		{
			_interactionFilter.collisionGroup = (this.collisionType ? this.collisionType.bits : 1);
			_interactionFilter.collisionMask = (this.collidesWithTypes ? this.collidesWithTypes.bits : -1);
			return _interactionFilter;
		}
		
		public function castRay(start:Point, end:Point, flags:ObjectType, result:RayHitInfo):Boolean
		{
			return false;
		}
		
		public function pointOccupied(pos:Point, mask:ObjectType, scene:IScene2D):Boolean
		{
			// If no sprite then we just test our bounds.
			if(!spriteForPointChecks && _size && _size.x > 0 && _size.y > 0)
				return worldExtents.containsPoint(pos);
			
			if(!scene && spriteForPointChecks && spriteForPointChecks.scene)
				scene = spriteForPointChecks.scene;
			
			if(spriteForPointChecks && scene)
				return spriteForPointChecks.pointOccupied(scene.transformScreenToWorld(pos), mask);
			
			//Check Nape body
			if(_body && scene){
				var worldPoint : Point = scene.transformScreenToWorld( pos );
				var tempVec : Vec2 = Vec2.get(worldPoint.x*_spatialManager.inverseScale, worldPoint.y*_spatialManager.inverseScale);
				var contained : Boolean = _body.contains( tempVec );
				tempVec.dispose();
				return contained;
			}
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
			//Because Nape STATIC bodies can not have shapes removed from them we have to remove it
			//from the space first.
			if ( _body.space && bodyType == BodyTypeEnum.STATIC )
			{
				space = _body.space;
				_body.space = null;
			}
			
			clearShapesFromBody();
			
			if (_collisionShapes && _collisionShapes.length > 0)
			{
				for each (var newShape:CollisionShape in _collisionShapes){
					newShape.createShape(this).body = _body;
				}
				_body.debugDraw = true;
			}else{
				var tmpShape : Polygon = new Polygon( Polygon.rect(-(_size.x/2)*_spatialManager.inverseScale, -(_size.y/2)*_spatialManager.inverseScale, _size.x*_spatialManager.inverseScale, _size.y*_spatialManager.inverseScale) );
				tmpShape.body = _body;
				if(PBE.IN_EDITOR)
					_body.debugDraw = false;
			}
			
			if ( _spatialManager && _spatialManager.space && _body.space != _spatialManager.space)
				_body.space = _spatialManager.space;
		}
		
		override public function onTick(deltaTime:Number):void
		{
			super.onTick(deltaTime);
			
			if(_debugDisplayEnabled && _shapeDebug && _spatialManager && !PBE.IS_SHIPPING_BUILD){
				_shapeDebug.clear();
				_shapeDebug.transform.setAs(_spatialManager.scale, 0, 0, _spatialManager.scale, 0, 0);
				_shapeDebug.draw(_body);
				_shapeDebug.flush();
				if(_debugLayerSceneTracking && _spriteForPointChecks && _spriteForPointChecks.scene){
					_shapeDebug.display.x = _spriteForPointChecks.scene.position.x;
					_shapeDebug.display.y = _spriteForPointChecks.scene.position.y;
				}
			}
		}
		
		override protected function onAdd():void
		{
			super.onAdd();
			if(! _collisionShapes){
				_collisionShapes = [ new CircleCollisionShape() ];
			}
			setupBody();
			attachRenderer();
			
			if(!PBE.IS_SHIPPING_BUILD){
				_shapeDebug = new ShapeDebug(PBUtil.clamp(PBE.mainClass.width, 10, 5000000), PBUtil.clamp(PBE.mainClass.height, 10, 5000000), 0x4D4D4D );
				_shapeDebug.drawConstraints = true;
				_shapeDebug.drawBodies = true;
				
				if(_spatialManager)
					debugDisplayEnabled = _spatialManager.visualDebugging ? false : true;
				if(debugDisplayEnabled)
					PBE.mainStage.addChild( _shapeDebug.display );
			}
		}
		
		override protected function onRemove():void
		{
			super.onRemove();
			destroyBody();
		}
		
		override protected function onReset():void
		{
			super.onReset();
			
			if(spriteForPointChecks && (spriteForPointChecks.owner == null || spriteForPointChecks.owner != this.owner))
				_spriteForPointChecks = null;
			
			attachRenderer();
		}

		private function destroyBody():void
		{
			if ( _body )
			{
				clearShapesFromBody();
				
				_body.space = null;
				//_body.clear();
				_body = null;
			}
			if(_shapeDebug && _shapeDebug.display)
			{
				if(PBE.mainStage.contains(_shapeDebug.display))
					PBE.mainStage.removeChild( _shapeDebug.display );
				_shapeDebug.clear();
				_shapeDebug = null;
			}
		}
		
		private function clearShapesFromBody():void
		{
			var shapeList:ShapeList = _body.shapes;
			for(var i : int = 0; i < shapeList.length; i++)
			{
				var shape : Shape = shapeList.at(i);
				shape.body = null;
			}
			_body.shapes.clear();
		}
		
		private function setupBody():void
		{
			if((_spatialManager == null) || (_spatialManager != null && _body != null))
				return;
			
			var invScale:Number = _spatialManager.inverseScale;
			
			_body = new Body(napeBodyType);
			_body.position.setxy(_position.x*invScale, _position.y*invScale);
			_body.rotation = PBUtil.getRadiansFromDegrees(_rotation);
			_body.isBullet = _collidesContinuously;
			_body.allowMovement = _canMove;
			_body.allowRotation = _canRotate;
			_body.velocity.setxy(_linearVelocity.x, _linearVelocity.y);
			_body.angularVel = PBUtil.getRadiansFromDegrees(angularVelocity);
			_body.cbTypes.add(_spatialManager.bodyCallbackType);
			_body.userData.spatial = this;
			_body.space = _spatialManager.space;
			buildCollisionShapes();
		}
		
		private function attachRenderer():void
		{
			if(!spriteForPointChecks){
				var renderer : DisplayObjectRenderer = owner.lookupComponentByType( DisplayObjectRenderer) as DisplayObjectRenderer;
				if(renderer && (!renderer.positionProperty || renderer.positionProperty.property == "" || (renderer.positionProperty && renderer.positionProperty.property.split(".")[0].indexOf("@"+this.name) != -1)))
					spriteForPointChecks = renderer;
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
		
		protected var _shapeDebug:ShapeDebug;
		protected var _debugLayerSceneTracking:Boolean = true;
		protected var _linearVelocity:Point = new Point(0, 0);
		protected var _angularVelocity:Number = 0.0;
		protected var _position:Point = new Point();
		protected var _rotation:Number = 0;
		protected var _size:Point = new Point(1,1);
		
		
	}
}