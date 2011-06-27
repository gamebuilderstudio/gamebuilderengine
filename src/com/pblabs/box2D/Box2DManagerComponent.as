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
    import Box2DAS.Collision.AABB;
    import Box2DAS.Collision.Shapes.b2Shape;
    import Box2DAS.Collision.b2AABB;
    import Box2DAS.Common.*;
    import Box2DAS.Controllers.b2Controller;
    import Box2DAS.Dynamics.*;
    import Box2DAS.Dynamics.Joints.*;
    
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.core.IAnimatedObject;
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
    
    import flash.display.Shape;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    public class Box2DManagerComponent extends EntityComponent implements ITickedObject, IAnimatedObject, ISpatialManager2D
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
        
		[EditorData(defaultValue="false")]
		public function get visualDebugging():Boolean
		{
			return _visualDebugging;
		}
		
		public function set visualDebugging(value:Boolean):void
		{
			_visualDebugging = value;
			if(!_debugDrawer) return;
			
			if(_visualDebugging)
				_debugDrawer.Draw();
			else
				_debugDrawer.ClearAll();
		}
		
		public function get debugDisplay():Shape
		{
			return _debugDrawer;
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
                _world.SetGravity( V2.fromP(_gravity) );
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
			PBE.processManager.addAnimatedObject(this);
            createWorld();
        }
        
        override protected function onRemove():void 
        {
            var body:b2Body = _world.GetBodyList();
            //the world is locked. this was called from a collision or other event.
            //defer until we know it should not be locked anymore.
            if (_world.IsLocked())
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
				_debugDrawer.world = null;
				_debugDrawer = null;
                
                PBE.processManager.removeTickedObject(this);
				PBE.processManager.removeAnimatedObject(this);
            }
        }
        
		public function addBody(bodyDef:b2BodyDef, thisArg:* = null, completedCallback:Function = null):void
        {
            if (!_world)
                throw new Error("World not initialized.");
            
            //the world is locked. this was called from a collision or other event.
            //defer until we know it should not be locked anymore.
            if (_world.IsLocked())
            {
				PBE.processManager.schedule(0, thisArg, addBody, bodyDef, thisArg, completedCallback );
            }
            else
            {
                var body:b2Body = _world.CreateBody(bodyDef);
                if (completedCallback != null)
                    completedCallback.apply(thisArg, [body]);
            }
        }
        
		public function removeBody(body:b2Body):void
        {
            if (_world)
            {
                //the world is locked. this was called from a collision or other event.
                //defer until we know it should not be locked anymore.
                if (_world.IsLocked())
                    PBE.processManager.schedule(0, this, removeBody, body);
                else
                    _world.DestroyBody(body);
            }
        }
        
        public function onTick(tickRate:Number):void
        {
            _world.Step(tickRate, 10, 1);
			_world.ClearForces();
        }
		
		public function onFrame(deltaTime:Number):void {
			if(_visualDebugging)
				_debugDrawer.Draw();
		}
        
        public function onInterpolateTick(factor:Number):void
        {
        }
		
		public function addJoint(jointDef:b2JointDef, thisArg:* = null, completedCallback:Function = null):void
        {
        	if (!_world)
                throw new Error("World not initialized.");
            
            //the world is locked. this was called from a collision or other event.
            //defer until we know it should not be locked anymore.
            if (_world.IsLocked())
            {
            	PBE.processManager.schedule(0, thisArg, addJoint, jointDef, thisArg, completedCallback);
            }else{
				var joint:b2Joint = _world.CreateJoint(jointDef);
                if (completedCallback != null)
                    completedCallback.apply(thisArg, [joint]);
           	}
		}
		
		public function removeJoint(joint:b2Joint):void
		{
			if (_world)
			{
				//the world is locked. this was called from a collision or other event.
                //defer until we know it should not be locked anymore.
                if (_world.IsLocked())
                    PBE.processManager.schedule(0, this, removeJoint, joint);
                else
                    _world.DestroyJoint(joint);
			}
		}
		
		public function addController(controller:b2Controller, thisArg:* = null, completedCallback:Function = null):void 
		{
			if (!_world)
				throw new Error("World not initialized.");
					
			if (_world.IsLocked())
			{
				PBE.processManager.schedule(0, thisArg, addController, controller, thisArg, completedCallback);
			}
			else
			{
				_world.AddController(controller);
				if (completedCallback != null)
					completedCallback.apply(thisArg, [controller]);
			}
		}
			
		public function removeController(controller:b2Controller):void 
		{
			if (_world)
			{
				if (_world.IsLocked())
					PBE.processManager.schedule(0, this, removeController, controller);
				else
					_world.RemoveController(controller);
			}
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
			//Query Box2D.
			var aabb:AABB = new AABB(new V2(box.topLeft.x / scale, box.topLeft.y / scale), new V2(box.bottomRight.x / scale, box.bottomRight.y / scale));

			var resultFixtures:Array = new Array(1024);
			var numFoundShapes:int;
			
			function callback(fixture:b2Fixture):Boolean {
					resultFixtures.push(fixture);
					return true;
			}
			_world.QueryAABB(callback, aabb);
			numFoundShapes = resultFixtures.length;
			
			var i:int = 0;
			if(numFoundShapes > 0)
			{
				// Now get the owning components back from the results and give to user.
				for(i=0; i<1024; i++)
				{
					if(!resultFixtures[i])
						break;
					var curFixture:b2Fixture = resultFixtures[i] as b2Fixture;
					var curComponent:Box2DSpatialComponent = curFixture.GetBody().GetUserData() as Box2DSpatialComponent;
					if(PBE.objectTypeManager.doTypesOverlap(curComponent.collisionType, mask) || mask == null)
						results.push(curComponent);
				}
			}
			
			// Let the other items have a turn.
			i += _otherItems.queryRectangle(box, mask, results) ? 1 : 0;
			
			// If we made it anywhere with i, then we got a result.
			return (i != 0);
			
			return false;
        }
        
        public function queryCircle(center:Point, radius:Number, mask:ObjectType, results:Array):Boolean
        {
			//Let's make life easy. We'll just use queryRectangle.
			//queryRectangle(box:Rectangle, mask:ObjectType, results:Array):Boolean
			var box:Rectangle = new Rectangle(center.x - radius / 2, center.y - radius / 2, radius, radius );
			
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
           /* var bounds:b2AABB = new b2AABB();
            bounds.lowerBound.SetV( new V2(_worldBounds.x / _scale, _worldBounds.y / _scale) );
            bounds.upperBound.SetV( new V2( (_worldBounds.x + _worldBounds.width) / _scale, (_worldBounds.y + _worldBounds.height) / _scale) );*/
			//ADDED: TODO: Fix to use the bounds property 
			//_world = new b2World(bounds, b2Vec2.Make(_gravity.x, _gravity.y), _allowSleep);
            _world = new b2World(V2.fromP(_gravity), _allowSleep);
            _world.SetContactFilter(new ContactFilter());
            _world.SetContactListener(new ContactListener());
			
			_debugDrawer = new b2DebugDraw();
			_debugDrawer.world = _world;
			_debugDrawer.scale = _scale;

        }
        
        // Used to store other world objects that aren't implemented by Box2D.
        protected var _otherItems:BasicSpatialManager2D = new BasicSpatialManager2D();      
        protected var _scale:Number = 30;
        protected var _world:b2World = null;
		protected var _debugDrawer:b2DebugDraw = null;
        protected var _allowSleep:Boolean = true;
		protected var _visualDebugging:Boolean = false;
        protected var _worldBounds:Rectangle = new Rectangle(-5000, -5000, 10000, 10000);
        protected var _gravity:Point = new Point(0, 9.81);
    }
}
