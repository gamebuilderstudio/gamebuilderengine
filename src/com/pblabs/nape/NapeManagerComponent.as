package com.pblabs.nape
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.PBUtil;
	import com.pblabs.engine.core.IAnimatedObject;
	import com.pblabs.engine.core.ObjectType;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.entity.EntityComponent;
	import com.pblabs.physics.IPhysics2DManager;
	import com.pblabs.rendering2D.BasicSpatialManager2D;
	import com.pblabs.rendering2D.ISpatialObject2D;
	import com.pblabs.rendering2D.RayHitInfo;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.dynamics.Arbiter;
	import nape.dynamics.InteractionFilter;
	import nape.geom.AABB;
	import nape.geom.Ray;
	import nape.geom.RayResult;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyList;
	import nape.space.Broadphase;
	import nape.space.Space;
	import nape.util.ShapeDebug;
	
	public class NapeManagerComponent extends EntityComponent implements IAnimatedObject, IPhysics2DManager
	{
		public function NapeManagerComponent()
		{
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		public function get ignoreTimeScale():Boolean { return _ignoreTimeScale; }
		public function set ignoreTimeScale(val:Boolean):void
		{
			_ignoreTimeScale = val;
		}

		public function get space():Space
		{
			return _space;
		}
		
		[EditorData(defaultValue="1")]
		public function get scale():Number
		{
			return _scale;
		}
		
		public function set scale(value:Number):void
		{
			_scale = value;
		}
		
		public function get inverseScale():Number
		{
			return 1 / _scale;
		}
		public function get gravity():Point
		{
			return _gravity;
		}
		
		public function set gravity(value:Point):void
		{
			_gravity = value;
			
			if ( _space )
				_space.gravity.setxy(_gravity.x, _gravity.y);
		}
		
		public function get velocityIterations():int
		{
			return _velocityIterations;
		}
		
		public function set velocityIterations(value:int):void
		{
			_velocityIterations = value;
		}

		public function get positionIterations():int
		{
			return _positionIterations;
		}
		
		public function set positionIterations(value:int):void
		{
			_positionIterations = value;
		}

		public function get materialManager():NapeMaterialManager
		{
			if(!_materialManager)
				_materialManager = NapeMaterialManager.instance;
			return _materialManager;
		}
		
		public function set materialManager(value:NapeMaterialManager):void
		{
			if (_materialManager && _materialManager != NapeMaterialManager.instance)
				throw new Error("Material manager already set!");
			_materialManager = value;
		}
		
		public function get visualDebugging():Boolean
		{
			return _visualDebugging;
		}
		
		public function set visualDebugging(value:Boolean):void
		{
			_visualDebugging = value;
			if(_visualDebugging){
				initDebugDraw();
				_shapeDebug.draw(_space);
			}else{
				if(_shapeDebug){
					_shapeDebug.clear();
					_shapeDebug = null;
				}
			}
		}
		
		public function get shapeDebugger() : ShapeDebug
		{
			return _shapeDebug;
		}

		public function get debugDrawer() : DisplayObject
		{
			if(!_shapeDebug)
				return null;
			return _shapeDebug.display;
		}

		public function get bodyCallbackType():CbType
		{
			return _bodyCallbackType;
		}
		
		[EditorData(defaultValue="true")]
		public function get allowSleep():Boolean
		{
			return _allowSleep;
		}
		
		public function set allowSleep(value:Boolean):void
		{
		
		}
		
		[EditorData(defaultValue="-10000|-10000|20000|20000")]
		public function get worldBounds():Rectangle
		{
			return _worldBounds;
		}
		
		public function set worldBounds(value:Rectangle):void
		{
			if (_space)
			{
				Logger.warn(this, "WorldBounds", "This property cannot be changed once the world has been created!");
				return;
			}
			/*_worldBounds.x = _space.world.bounds.x*scale;
			_worldBounds.y = _space.world.bounds.y*scale;
			_worldBounds.width = _space.world.bounds.width*scale;
			_worldBounds.height = _space.world.bounds.height*scale;*/
			_worldBounds = value;
		}

		public function get debugLayerPosition():Point
		{
			return _debugLayerPosition;
		}
		
		public function set debugLayerPosition(value:Point):void
		{
			_debugLayerPosition = value;
		}

		public function get spatialObjectList():Vector.<INape2DSpatialComponent>
		{
			return _physicsObjectList.concat();
		}

		public function onFrame(dt:Number):void
		{
			if(_physicsObjectList.length < 1){
				if(_space && _shapeDebug && _visualDebugging)
				{
					_shapeDebug.clear();
				}
				return;
			}
			
			if(_space && !PBE.IN_EDITOR){
				_simulationTime += dt;
				// Keep on stepping forward by fixed time step until amount of time
				// needed has been simulated.
				while (space.elapsedTime < _simulationTime) {
					_space.step(1 / PBE.mainStage.frameRate, _velocityIterations, _positionIterations);
				}
				
			}
			if(_space && _shapeDebug && _visualDebugging){
				_shapeDebug.clear();
				var len : int = _physicsObjectList.length;
				var trakedObjectFound : Boolean = false;
				for(var i : int = 0; i < len; i++)
				{
					//Try to convert object body positions to global coordinate space
					if(_physicsObjectList[i].spriteForPointChecks && _physicsObjectList[i].spriteForPointChecks.scene && "trackObject" in _physicsObjectList[i].spriteForPointChecks.scene && _physicsObjectList[i].spriteForPointChecks.scene["trackObject"] )
					{
						trakedObjectFound = true;
						_debugLayerPosition.copyFrom(_physicsObjectList[i].spriteForPointChecks.scene.position);
						_shapeDebug.transform.setAs(1,0,0,1, _debugLayerPosition.x, _debugLayerPosition.y);
						break;
					}
				}
				if(!trakedObjectFound && !PBE.IN_EDITOR)
					_shapeDebug.transform.setAs(1,0,0,1, _debugLayerPosition.x, _debugLayerPosition.y);
				_shapeDebug.draw(_space);
				_shapeDebug.flush();
			}
		}
		
		public function addSpatialObject(object:ISpatialObject2D):void
		{
			if(object is INape2DSpatialComponent && _physicsObjectList.indexOf(object as INape2DSpatialComponent) == -1){
				_physicsObjectList.push( object );
				if(!_space)
					initSpace();			
			}else if(!(object is INape2DSpatialComponent)){
				_otherItems.addSpatialObject(object);
			}
		}
		
		public function removeSpatialObject(object:ISpatialObject2D):void
		{
			if(object is INape2DSpatialComponent && _physicsObjectList.indexOf(object as INape2DSpatialComponent) != -1){
				_physicsObjectList.splice(_physicsObjectList.indexOf(object as INape2DSpatialComponent), 1);
			}else if(!(object is INape2DSpatialComponent)){
				_otherItems.removeSpatialObject(object);
			}
		}
		
		public function queryRectangle(box:Rectangle, mask:ObjectType, results:Array):Boolean
		{
			var numFoundBodies:int = 0;
			if(_space)
			{
				if(box.width <= 1 || box.height <= 1)
					box.inflate(5, 5);
				
				//query aabb
				var aabb:AABB = new AABB(box.left*inverseScale, box.top*inverseScale, box.width*inverseScale, box.height*inverseScale);
				//setup filter
				_queryInteraction.collisionGroup = -1;
				_queryInteraction.collisionMask = (mask ? mask.bits : -1);
				
				
				var bodyList:BodyList = _space.bodiesInAABB(aabb, false, true, _queryInteraction);			
				numFoundBodies = bodyList.length;
				for(var i : int = 0; i < numFoundBodies; i++)
				{
					var item : Body = bodyList.at(i);
					var curComponent:NapeSpatialComponent = item.userData.spatial;
					if ( !curComponent )	//so what should we do? is it even possible?
					{
						Logger.error(this, "queryRectangle", "Body user data must contain spatialComponent!");
						continue;
					}
					results.push(curComponent);				
				}
				bodyList.clear();
			}
			// Let the other items have a turn.
			numFoundBodies += _otherItems.queryRectangle(box, mask, results) ? 1 : 0;
			
			// If we made it anywhere with i, then we got a result.
			return (numFoundBodies != 0);
			
			return false;
		}
		
		public function queryCircle(center:Point, radius:Number, mask:ObjectType, results:Array):Boolean
		{
			var numFoundBodies:int = 0;
			if(_space){
				//query aabb
				var pos:Vec2 = Vec2.get(center.x*inverseScale, center.y*inverseScale);
				//setup filter
				_queryInteraction.collisionGroup = -1;
				_queryInteraction.collisionMask = (mask ? mask.bits : -1);
				
				var bodyList:BodyList = _space.bodiesInCircle(pos, radius*inverseScale, false, _queryInteraction);
				
				numFoundBodies = bodyList.length;
				for(var i : int = 0; i < numFoundBodies; i++)
				{
					var item : Body = bodyList.at(i);
					var curComponent:NapeSpatialComponent = item.userData.spatial;
					if ( !curComponent )	//so what should we do? is it even possible?
					{
						Logger.error(this, "queryCircle", "Body user data must contain spatialComponent!");
						continue;
					}
					results.push(curComponent);				
				}
	
				bodyList.clear();
				pos.dispose();
			}
			// Let the other items have a turn.
			numFoundBodies += _otherItems.queryCircle(center, radius, mask, results)  ? 1 : 0;
			// If we made it anywhere with i, then we got a result.
			return (numFoundBodies != 0);
		}
		
		public function castRay(start:Point, end:Point, mask:ObjectType, result:RayHitInfo):Boolean
		{
			if(_space){
				var startVec : Vec2 = Vec2.get(start.x*inverseScale, start.y*inverseScale, true);
				var endVec : Vec2 = Vec2.get(end.x*inverseScale, end.y*inverseScale, true);
				
				var ray:Ray = Ray.fromSegment(startVec, endVec);
				_queryInteraction.collisionGroup = -1;
				_queryInteraction.collisionMask = (mask ? mask.bits : -1);
				var napeResult:RayResult = _space.rayCast(ray, false, _queryInteraction);
				startVec.dispose();
				endVec.dispose();
				if ( napeResult )
				{
					//convert nape result to RayHitInfo
					result.time = napeResult.distance/ray.maxDistance;
					result.normal = new Point(napeResult.normal.x, napeResult.normal.y);
					var contact:Vec2 = ray.at(napeResult.distance);
					result.position = new Point(contact.x*_scale, contact.y*_scale);
					result.hitObject = napeResult.shape.body.userData.spatial;
					napeResult.dispose();
					contact.dispose();
					return true;
				}
			}
			return _otherItems.castRay(start, end, mask, result);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getObjectsUnderPoint(worldPosition:Point, results:Array, mask:ObjectType = null):Boolean
		{
			var numFoundBodies:int = 0;
			if(_space){
				_queryInteraction.collisionGroup = -1;
				_queryInteraction.collisionMask = (mask ? mask.bits : -1);
				var worldPoint : Vec2 = Vec2.get(worldPosition.x*inverseScale, worldPosition.y*inverseScale);
				var bodyList:BodyList = _space.bodiesUnderPoint(worldPoint, _queryInteraction);
				
				numFoundBodies = bodyList.length;
				for(var i : int = 0; i < numFoundBodies; i++)
				{
					var item : Body = bodyList.at(i);
					var curComponent:NapeSpatialComponent = item.userData.spatial;
					if ( !curComponent )	//so what should we do? is it even possible?
					{
						Logger.error(this, "getObjectsUnderPoint", "Body user data must contain spatialComponent!");
						continue;
					}
					if(!results)
						results = new Array();
					results.push(curComponent);				
				}
				bodyList.clear();
				worldPoint.dispose();
			}

			// Let the other items have a turn.
			numFoundBodies += _otherItems.getObjectsUnderPoint(worldPosition, results, mask)  ? 1 : 0;
			
			// If we made it anywhere with i, then we got a result.
			return (numFoundBodies != 0);
			
			return false;
		}
		
		/**
		 * Grab all spatials within a rectangular region
		 */
		public function getObjectsInRec(worldRec:Rectangle, results:Array):Boolean
		{
			// First use the normal spatial query...
			queryRectangle(worldRec, null, results);
			
			// Ok, now pass control to the objects and see what they think.
			return _otherItems.getObjectsInRec(worldRec, results);
		}

		override protected function onAdd():void
		{
			super.onAdd();
			_bodyCallbackType = new CbType();
			//provide default material manager
			if (!_materialManager)
				_materialManager = NapeMaterialManager.instance;
			PBE.processManager.addAnimatedObject(this, 1000);
			initSpace();
		}
		
		override protected function onRemove():void
		{
			freeSpace();
			PBE.processManager.removeAnimatedObject(this);
			super.onRemove();
		}
		
		private function initSpace():void
		{
			if((PBE.IS_SHIPPING_BUILD && _physicsObjectList.length < 1) || _space)
				return;
			_space = new Space(new Vec2(_gravity.x, _gravity.y), Broadphase.DYNAMIC_AABB_TREE);
			
			_space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, _bodyCallbackType, _bodyCallbackType, beginCollisionCallback));
			_space.listeners.add(new InteractionListener(CbEvent.END, InteractionType.COLLISION, _bodyCallbackType, _bodyCallbackType, endCollisionCallback));
			
			_space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR, _bodyCallbackType, _bodyCallbackType, beginCollisionCallback));
			_space.listeners.add(new InteractionListener(CbEvent.END, InteractionType.SENSOR, _bodyCallbackType, _bodyCallbackType, endCollisionCallback));
			if(_visualDebugging)
				initDebugDraw();
		}
		
		private function initDebugDraw():void
		{
			if(_shapeDebug)
				_shapeDebug.clear();
			_shapeDebug = new ShapeDebug(PBUtil.clamp(PBE.mainStage.stageWidth*2, 10, 5000000), PBUtil.clamp(PBE.mainStage.stageHeight*2, 10, 5000000), 0x4D4D4D );
			_shapeDebug.drawConstraints = true;
			_shapeDebug.drawBodies = true;
			_shapeDebug.thickness = 1;
			if(!PBE.IN_EDITOR)
				PBE.mainStage.addChild( _shapeDebug.display );
		}
		
		private function freeSpace():void
		{
			_space.listeners.clear();
			_space.clear();
			
			if(_shapeDebug)
				_shapeDebug.clear();
			
			_materialManager = null;
		}
		
		private function beginCollisionCallback(cb:InteractionCallback):void
		{
			var len : int = cb.arbiters.length;
			for(var i : int = 0; i < len; i++)
			{
				var item : Arbiter = cb.arbiters.at(i);
				dispatchCollisionEvents(item, CollisionEvent.COLLISION_EVENT);
			}
		}
		
		private function endCollisionCallback(cb:InteractionCallback):void
		{
			var spatial1:NapeSpatialComponent = cb.int1.userData.spatial;
			var spatial2:NapeSpatialComponent = cb.int2.userData.spatial;
			var ce:CollisionEvent = new CollisionEvent(CollisionEvent.COLLISION_STOPPED_EVENT, spatial1, spatial2, new Point(), null, null);
			if ( spatial1.owner )
				spatial1.owner.eventDispatcher.dispatchEvent(ce);
			if ( spatial2.owner )
				spatial2.owner.eventDispatcher.dispatchEvent(ce);

		}

		private function dispatchCollisionEvents(arbiter:Arbiter, eventType:String):void
		{
			var spatial1:NapeSpatialComponent = arbiter.body1.userData.spatial;
			var spatial2:NapeSpatialComponent = arbiter.body2.userData.spatial;
			var ce:CollisionEvent;

			var isCollision : Boolean = arbiter.isCollisionArbiter();
			var isSensorTrigger : Boolean = arbiter.isSensorArbiter();
			if ( isCollision )
			{
				ce = new CollisionEvent(eventType, spatial1, spatial2, new Point(arbiter.collisionArbiter.normal.x, arbiter.collisionArbiter.normal.y), arbiter.collisionArbiter.contacts, arbiter.collisionArbiter);
			}else if( isSensorTrigger ){
				ce = new CollisionEvent(eventType, spatial1, spatial2, new Point(), null, null);
			}
			if ( spatial1.owner)
				spatial1.owner.eventDispatcher.dispatchEvent(ce);
			if ( spatial2.owner)
				spatial2.owner.eventDispatcher.dispatchEvent(ce);
		}
		
		protected var _scale:Number = 1;
		protected var _space:Space;
		protected var _shapeDebug:ShapeDebug;
		protected var _velocityIterations:int = 10;
		protected var _positionIterations:int = 10;
		protected var _gravity:Point = new Point(0, 600);
		protected var _otherItems:BasicSpatialManager2D = new BasicSpatialManager2D();
		protected var _materialManager:NapeMaterialManager;
		protected var _allowSleep : Boolean = true;
		protected var _worldBounds:Rectangle = new Rectangle(-5000, -5000, 10000, 10000);
		protected var _queryInteraction:InteractionFilter = new InteractionFilter();
		protected var _physicsObjectList:Vector.<INape2DSpatialComponent> = new Vector.<INape2DSpatialComponent>();
		protected var _simulationTime : Number = 0;
		protected var _debugLayerPosition:Point = new Point(0, 0);
		
		private var _visualDebugging:Boolean = false;
		private var _visualDebuggingPending:Boolean = false;
		private var _bodyCallbackType:CbType;
		private var _ignoreTimeScale : Boolean = false;
		
	}
}