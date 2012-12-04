/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.rendering2D
{
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.components.TickedComponent;
    import com.pblabs.engine.core.ObjectType;
    
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    /**
     * Very basic spatial component that exists at a position. Velocity can be
     * applied, but no physical simulation is done.
     */ 
    public class SimpleSpatialComponent extends TickedComponent implements IMobileSpatialObject2D
    {
		public function get linearVelocity():Point
		{
			return _linearVelocity;
		}
		
		public function set linearVelocity(value:Point):void
		{
			_linearVelocity = value;
		}

		public function get size():Point
        {
            return _size;
        }
        
        public function set size(value:Point):void
        {
            _size = value;
        }
        
        public function get position():Point
        {
            return _position.clone();
        }
        
        public function set position(value:Point):void
        {
            _position.x = value.x;
            _position.y = value.y;
        }
		
        [EditorData(ignore="true")]
        public function set x(value:Number):void
        {
            _position.x = value;
        }
        
        public function get x():Number
        {
            return _position.x;
        }
        
		[EditorData(ignore="true")]
        public function set y(value:Number):void
        {
            _position.y = value;
        }
        
        public function get y():Number
        {
            return _position.y;
        }

        public function get rotation():Number
        {
            return _rotation;
        }
        
        public function set rotation(value:Number):void
        {
            _rotation = value;
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

		/**
         * The spatial manager this object belongs to.
         */
        [EditorData(referenceType="componentReference")]
        public function get spatialManager():ISpatialManager2D
        {
            return _spatialManager;
        }
        
        public function set spatialManager(value:ISpatialManager2D):void
        {
            if (!isRegistered)
            {
                _spatialManager = value;
                return;
            }
            
            if (_spatialManager)
                _spatialManager.removeSpatialObject(this);
            
            _spatialManager = value;
            
            if (_spatialManager)
                _spatialManager.addSpatialObject(this);
        }
        
        /**
         * The position of the object.
         */
        private var _position:Point = new Point(0, 0);
        
        /**
         * The rotation of the object.
         */
        private var _rotation:Number = 0;
        
        /**
         * The size of the object.
         */
        [EditorData(defaultValue="100|100")]
        private var _size:Point = new Point(100, 100);
        
        /**
         * The linear linearVelocity of the object in world units per second.
         */
        private var _linearVelocity:Point = new Point(0, 0);
        
        /**
         * The angular linearVelocity of the object in degrees per second.
         */
        public var angularVelocity:Number = 0;
        
        /**
         * @inheritDoc
         */
        override public function onTick(tickRate:Number):void
        {
            // Note we set directly, as position (the accessor) clones the point,
            // which would result in a nop.
            _position.x += linearVelocity.x * tickRate;
            _position.y += linearVelocity.y * tickRate;
            rotation   += angularVelocity * tickRate;
        }
        
        /**
         * @inheritDoc
         */
        override protected function onAdd():void
        {
            super.onAdd();
            
            if (_spatialManager)
                _spatialManager.addSpatialObject(this);

			attachRenderer();
		}
        
        /**
         * @inheritDoc
         */
        override protected function onRemove():void
        {
            super.onRemove();
            
            if (_spatialManager)
                _spatialManager.removeSpatialObject(this);
        }
		
		override protected function onReset():void
		{
			super.onReset();
			
			if(spriteForPointChecks && (spriteForPointChecks.owner == null || spriteForPointChecks.owner != this.owner))
				_spriteForPointChecks = null;
			
			attachRenderer();
		}
		
		private function attachRenderer():void
		{
			if(!spriteForPointChecks){
				var renderer : DisplayObjectRenderer = owner.lookupComponentByType( DisplayObjectRenderer) as DisplayObjectRenderer;
				if(renderer && (!renderer.positionProperty || renderer.positionProperty.property == "" || (renderer.positionProperty && renderer.positionProperty.property.split(".")[0].indexOf("@"+this.name) != -1)))
					spriteForPointChecks = renderer;
			}
		}
        
        /**
         * @inheritDoc
         */
        public function get objectMask():ObjectType
        {
            return _objectMask;
        }
        
        /**
         * @private
         */
        public function set objectMask(value:ObjectType):void
        {
            _objectMask = value;
        }
        
        /**
         * @inheritDoc
         */
        public function get worldExtents():Rectangle
        {
			if(spriteForPointChecks)
				return spriteForPointChecks.sceneBounds;
			
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
        public function pointOccupied(pos:Point, mask:ObjectType, scene:IScene2D):Boolean
        {
            // If no sprite then we just test our bounds.
            if(!spriteForPointChecks || !scene){
				var extents : Rectangle = worldExtents;
				if(!extents)
					return false;
                return extents.containsPoint(pos);
			}
            
			if(!scene && spriteForPointChecks && spriteForPointChecks.scene)
				scene = spriteForPointChecks.scene;

			// OK, so pass it over to the sprite.
            return spriteForPointChecks.pointOccupied(scene.transformWorldToScreen(pos), mask);
        }
        
        private var _objectMask:ObjectType;
        private var _spatialManager:ISpatialManager2D;
    }
}
