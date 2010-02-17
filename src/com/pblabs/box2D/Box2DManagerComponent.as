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
    import Box2D.Collision.Shapes.b2Shape;
    import Box2D.Collision.b2AABB;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;
    import Box2D.Dynamics.b2DebugDraw;
    import Box2D.Dynamics.b2World;
    
	import com.pblabs.engine.PBE;
    import com.pblabs.engine.core.ITickedObject;
    import com.pblabs.engine.core.ObjectType;
    import com.pblabs.engine.core.ObjectTypeManager;
    import com.pblabs.engine.core.ProcessManager;
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.engine.entity.EntityComponent;
    import com.pblabs.rendering2D.BasicSpatialManager2D;
    import com.pblabs.rendering2D.IScene2D;
    import com.pblabs.rendering2D.ISpatialManager2D;
    import com.pblabs.rendering2D.ISpatialObject2D;
    import com.pblabs.rendering2D.RayHitInfo;
    
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    public class Box2DManagerComponent extends EntityComponent implements ITickedObject, ISpatialManager2D
    {
        [EditorData(defaultValue="30")]
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
        
        public function get world():b2World
        {
            return _world;
        }
        [EditorData(defaultValue="true")]
        public function get allowSleep():Boolean
        {
            return _allowSleep;
        }
        
        public function set allowSleep(value:Boolean):void
        {
            if (_world)
            {
                Logger.warn(this, "AllowSleep", "This property cannot be changed once the world has been created!");
                return;
            }
            
            _allowSleep = value;
        }
        
        [EditorData(defaultValue="9.81")]
        public function get gravity():Point
        {
            return _gravity;
        }
        
        public function set gravity(value:Point):void
        {
            _gravity = value;
            
            if (_world)
                _world.SetGravity(new b2Vec2(value.x, value.y));
        }
        
        [EditorData(defaultValue="-10000|-10000|20000|20000")]
        public function get worldBounds():Rectangle
        {
            return _worldBounds;
        }
        
        public function set worldBounds(value:Rectangle):void
        {
            if (_world)
            {
                Logger.warn(this, "WorldBounds", "This property cannot be changed once the world has been created!");
                return;
            }
            
            _worldBounds = value;
        }
        
        override protected function onAdd():void
        {
            PBE.processManager.addTickedObject(this);
            createWorld();
        }
        
        override protected function onRemove():void 
        {
            var body:b2Body = _world.GetBodyList();
            //the world is locked. this was called from a collision or other event.
            //defer until we know it should not be locked anymore.
            if (_world.m_lock)
            {
                PBE.processManager.schedule(0, this, onRemove);
            }
            else
            {
                while (body)
                {
                    var next:b2Body = body.GetNext();
                    _world.DestroyBody(body);
                    body = next;
                }
                
                _world = null;
                
                PBE.processManager.removeTickedObject(this);
            }
        }
        
        public function add(bodyDef:b2BodyDef, thisArg:* = null, completedCallback:Function = null):void
        {
            if (!_world)
                throw new Error("World not initialized.");
            
            //the world is locked. this was called from a collision or other event.
            //defer until we know it should not be locked anymore.
            if (_world.m_lock)
            {
                PBE.processManager.schedule(0, thisArg, add, bodyDef, thisArg, completedCallback);
            }
            else
            {
                var body:b2Body = _world.CreateBody(bodyDef);
                if (completedCallback != null)
                    completedCallback.apply(thisArg, [body]);
            }
        }
        
        public function remove(body:b2Body):void
        {
            if (_world)
            {
                //the world is locked. this was called from a collision or other event.
                //defer until we know it should not be locked anymore.
                if (_world.m_lock)
                    PBE.processManager.schedule(0, this, remove, body);
                else
                    _world.DestroyBody(body);
            }
        }
        
        public function setDebugDrawer(drawer:b2DebugDraw):void
        {
            drawer.m_drawScale = _scale;
            _world.SetDebugDraw(drawer);
        }
        
        public function onTick(tickRate:Number):void
        {
            _world.Step(tickRate, 10);
        }
        
        public function onInterpolateTick(factor:Number):void
        {
        }
        
        public function addSpatialObject(object:ISpatialObject2D):void
        {
            _otherItems.addSpatialObject(object);
        }
        
        public function removeSpatialObject(object:ISpatialObject2D):void
        {
            _otherItems.removeSpatialObject(object);
        }
        
        public function queryRectangle(box:Rectangle, mask:ObjectType, results:Array):Boolean
        {
            // Query Box2D.
            var aabb:b2AABB = new b2AABB();
            aabb.lowerBound = b2Vec2.Make(box.topLeft.x / scale, box.topLeft.y / scale);
            aabb.upperBound = b2Vec2.Make(box.bottomRight.x / scale, box.bottomRight.y / scale);
            
            var resultShapes:Array = new Array(1024);
			var numFoundShapes:int = _world.Query(aabb, resultShapes, 1024);
            
			var i:int = 0;
			if(numFoundShapes > 0)
			{
				// Now get the owning components back from the results and give to user.
				for(i=0; i<1024; i++)
				{
					if(!resultShapes[i])
						break;
					
					var curShape:b2Shape = resultShapes[i] as b2Shape;
					var curComponent:Box2DSpatialComponent = curShape.GetBody().GetUserData() as Box2DSpatialComponent;
					if(PBE.objectTypeManager.doTypesOverlap(curComponent.collisionType, mask) || mask == null)
						results.push(curComponent);
				}
			}
            
            // Let the other items have a turn.
            i += _otherItems.queryRectangle(box, mask, results) ? 1 : 0;
            
            // If we made it anywhere with i, then we got a result.
            return (i != 0);
        }
        
        public function queryCircle(center:Point, radius:Number, mask:ObjectType, results:Array):Boolean
        {
			//Let's make life easy. We'll just use queryRectangle.
			//queryRectangle(box:Rectangle, mask:ObjectType, results:Array):Boolean
			var box:Rectangle = new Rectangle(center.x - radius / 2, center.y - radius / 2,
				radius, radius );
			
			//Query the Box2D objects:
			var foundObject:Boolean = queryRectangle(box, mask, results);
			
			//Note: no need to query for other objects, as this is also done in queryRectangle!
			//In case somebody wants to re-write the queryCircle, you'd wanna use _otherItems.queryCircle like 
			//commented out below:
			//Query the "other" spatial objects:
			//var tmpResults:Array = new Array();
			//var foundOtherObjects:Boolean = _otherItems.queryCircle(center, radius, mask, tmpResults);
			
			//If we found "other" spatial objects, add them to the result array:
			//if (foundOtherObjects == true)
			//{
			//	for (var i:int = 0; i < tmpResults.length; i++)
			//	{
			//		results.push(tmpResults[i]);
			//	}
			//}
			
			//return wheter we found object(s) or not:
			return foundObject; //|| foundOtherObjects;
        }
        
        public function castRay(start:Point, end:Point, mask:ObjectType, result:RayHitInfo):Boolean
        {
            return _otherItems.castRay(start, end, mask, result);
        }
        
        /**
         * @inheritDoc
         */
		public function getObjectsUnderPoint(worldPosition:Point, results:Array, mask:ObjectType = null):Boolean
        {
            var tmpResults:Array = new Array();
			
            // First use the normal spatial query...
            if(!queryCircle(worldPosition, 0.01, mask, tmpResults))
                return false;
            
            // Ok, now pass control to the objects and see what they think.
            var hitAny:Boolean = false;
            for each(var tmp:ISpatialObject2D in tmpResults)
            {
                if (!tmp.pointOccupied(worldPosition, mask, PBE.scene))
                    continue;
                
                results.push(tmp);
                hitAny = true;
            }
            
            return hitAny;
        }
        
        private function createWorld():void
        {
            var bounds:b2AABB = new b2AABB();
            bounds.lowerBound.Set(_worldBounds.x / _scale, _worldBounds.y / _scale);
            bounds.upperBound.Set((_worldBounds.x + _worldBounds.width) / _scale, (_worldBounds.y + _worldBounds.height) / _scale);
            _world = new b2World(bounds, new b2Vec2(_gravity.x, _gravity.y), _allowSleep);
            _world.SetContactFilter(new ContactFilter());
            _world.SetContactListener(new ContactListener());
        }
        
        // Used to store other world objects that aren't implemented by Box2D.
        protected var _otherItems:BasicSpatialManager2D = new BasicSpatialManager2D();      
        protected var _scale:Number = 30;
        protected var _world:b2World = null;
        protected var _allowSleep:Boolean = true;
        protected var _worldBounds:Rectangle = new Rectangle(-5000, -5000, 10000, 10000);
        protected var _gravity:Point = new Point(0, 9.81);
    }
}
