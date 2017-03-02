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

		public function get angularVelocity():Number
		{
			return _angularVelocity;
		}
		
		public function set angularVelocity(value:Number):void
		{
			_angularVelocity = value;
		}

		public function get size():Point
        {
            return _size;
        }
        
        public function set size(value:Point):void
        {
            _size = value;
        }
        
		public function get screenRelativePosition():Point
		{
			return _screenRelativePosition;
		}
		
		public function set screenRelativePosition(value:Point):void
		{
			_screenRelativePosition.setTo(value.x, value.y);
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
		
		public function get pinned():Boolean
		{
			return _pinned;
		}
		
		public function set pinned(value:Boolean):void
		{
			_pinned = value;
		}
		
		public function get horizontalPercent():Number
		{
			return _horizontalPercent;
		}
		
		public function set horizontalPercent(value:Number):void
		{
			_horizontalPercent = value
		}
		
		public function get horizontalEdge():String
		{
			return _horizontalEdge;
		}
		
		public function set horizontalEdge(value:String):void
		{
			_horizontalEdge = value;
		}
		
		public function get verticalPercent():Number
		{
			return _verticalPercent;
		}
		
		public function set verticalPercent(value:Number):void
		{
			_verticalPercent = value
		}
		
		public function get verticalEdge():String
		{
			return _verticalEdge;
		}
		
		public function set verticalEdge(value:String):void
		{
			_verticalEdge = value;
		}

		[EditorData(ignore="true", inspectable="true")]
        public function set x(value:Number):void
        {
            _position.x = value;
        }
        
        public function get x():Number
        {
            return _position.x;
        }
        
		[EditorData(ignore="true", inspectable="true")]
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
				size = value.size.clone();
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
        private var _angularVelocity:Number = 0;
        
        /**
         * @inheritDoc
         */
        override public function onTick(tickRate:Number):void
        {
			if(_pinned && _spriteForPointChecks && !PBE.IN_EDITOR)
			{
				_pinnedPosition.setTo( ((_horizontalEdge == "right") ? (PBE.mainStage.width - (PBE.mainStage.width * _horizontalPercent)) : (PBE.mainStage.width * _horizontalPercent)), ((_verticalEdge == "bottom") ? (PBE.mainStage.height - (PBE.mainStage.height * _verticalPercent)) : (PBE.mainStage.height * _verticalPercent)) );
				var tempScenePosition : Point = _spriteForPointChecks.scene.transformScreenToScene(_pinnedPosition);
				_position = tempScenePosition;
			}else if(!PBE.IN_EDITOR){
				// Note we set directly, as position (the accessor) clones the point,
				// which would result in a nop.
	            _position.x += linearVelocity.x * tickRate;
	            _position.y += linearVelocity.y * tickRate;
			}
			_rotation   += angularVelocity * tickRate;
			
			super.onTick(tickRate);
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
			
			if(this.isRegistered && (spriteForPointChecks && !spriteForPointChecks.isRegistered) && PBE.IN_EDITOR)
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
			if(spriteForPointChecks){
				var sceneBounds : Rectangle = spriteForPointChecks.sceneBounds;
				if(sceneBounds)
					return sceneBounds;
			}
			_worldExtents.setTo(position.x - (size.x * 0.5), position.y - (size.y * 0.5), size.x, size.y);
			return _worldExtents;         
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
        public function pointOccupied(pos:Point, mask:ObjectType, scene:IScene2D, convertFromStageCoordinates : Boolean = false):Boolean
        {
			// If no sprite then we just test our bounds.
			if(!spriteForPointChecks && _size && _size.x > 0 && _size.y > 0){
				var extents : Rectangle = worldExtents;
				if(!extents)
					return false;
				return extents.containsPoint(pos);
			}
			
			if(!scene && spriteForPointChecks && spriteForPointChecks.scene)
				scene = spriteForPointChecks.scene;

			if(scene && convertFromStageCoordinates)
				pos = scene.transformScreenToWorld(pos);
			// OK, so pass it over to the sprite.
            return spriteForPointChecks.pointOccupied(pos, mask);
        }
        
		protected var _pinned:Boolean = false;
		protected var _horizontalPercent:Number = 0;
		protected var _horizontalEdge:String = "left";
		protected var _verticalPercent:Number = 0;
		protected var _verticalEdge:String = "top";
		protected var _pinnedPosition:Point = new Point(0,0);
		protected var _screenRelativePosition:Point = new Point(0,0);

		private var _objectMask:ObjectType;
        private var _spatialManager:ISpatialManager2D;
		private var _worldExtents:Rectangle = new Rectangle();
    }
}
