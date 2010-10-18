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
    import com.pblabs.engine.PBUtil;
    import com.pblabs.engine.components.AnimatedComponent;
    import com.pblabs.engine.core.ObjectType;
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.engine.entity.PropertyReference;
    
    import flash.display.BlendMode;
    import flash.display.DisplayObject;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    /**
     * Base renderer for Rendering2D. It wraps a DisplayObject, allows it
     * to be controlled by PropertyReferences, and hooks it into a scene.
     *
     * <p>The various other renderers inherit from DisplayObjectRenderer,
     * and rely on it for basic functionality.</p>
     *
     * <p>Normally, the DisplayObjectRenderer tries to update itself
     * every frame. However, you can suppress this by setting
     * registerForUpdates to false, in which case you will have to
     * call onFrame()/updateTransform() manually if you change
     * something.</p>
     *
     * @see BitmapRenderer
     * @see SpriteSheetRenderer
     * @see MovieClipRenderer
     */
    public class DisplayObjectRenderer extends AnimatedComponent
    {
        /**
         * Reference value used for sorting in some scenes.
         */
        public var renderKey:int = 0;
        
        /**
         * If set, position is gotten from this property every frame.
         */
        public var positionProperty:PropertyReference;
        
        /**
         * if set this to false, positions will be handeled with numbers insteed of integers
         * makes slow movement smoother for example
         */
        public var snapToNearestPixels:Boolean = true;
        
        /**
         * If set, scale is gotten from this property every frame.
         */
        public var scaleProperty:PropertyReference;
        
        /**
         * If set, size is determined by this property every frame.
         */
        public var sizeProperty:PropertyReference;
        
        /**
         * If set, rotation is gotten from this property every frame.
         */
        public var rotationProperty:PropertyReference;
        
        /**
         * If set, alpha is gotten from this property every frame.
         */
        public var alphaProperty:PropertyReference;
		
		/**
		 * If set, blend mode is gotten from this property every frame.
		 */
		public var blendModeProperty:PropertyReference;
        
        /**
         * If set, the layer index is gotten from this property every frame.
         */
        public var layerIndexProperty:PropertyReference;
        
        /**
         * If set, our z-index is gotten from this property every frame.
         */
        public var zIndexProperty:PropertyReference;
        
        /**
         * If set, our registration point is gotten from this property every frame.
         *
         * <p>Note that some subclasses override this; for instance, the
         * SpriteSheetRenderer always uses the registrationPoint from the
         * sprite sheet it is rendering.</p>
         */
        public var registrationPointProperty:PropertyReference;
        
        /**
         * The types for this object; used for picking queries primarily.
         */
        public var objectMask:ObjectType;
        
        protected var _displayObject:DisplayObject;
        protected var _scene:IScene2D;
        
        protected var _layerIndex:int = 0;
        protected var _lastLayerIndex:int = -1;
        protected var _zIndex:int = 0;
        
        protected var _rotationOffset:Number = 0;
        protected var _registrationPoint:Point = new Point();
        protected var _scale:Point = new Point(1, 1);
        protected var _rotation:Number = 0;
        protected var _alpha:Number = 1;
		protected var _blendMode:String = BlendMode.NORMAL;
        protected var _position:Point = new Point();
		protected var _positionOffset:Point = new Point();
        protected var _size:Point;
        
        protected var _transformMatrix:Matrix = new Matrix();
        
        protected var _transformDirty:Boolean = true;
        protected var _layerIndexDirty:Boolean = true;
        protected var _zIndexDirty:Boolean = true;
        protected var _hitTestDirty:Boolean = true;
        
        protected var _inScene:Boolean = false;
        
		public function DisplayObjectRenderer()
		{
			_scene = PBE.scene;	// Default scene to PBE.scene
		}
		
        public function get layerIndex():int
        {
            return _layerIndex;
        }
        
        /**
         * In what layer of the scene is this renderer drawn?
         */
        public function set layerIndex(value:int):void
        {
            if (_layerIndex == value)
                return;
            
            _layerIndex = value;
            _layerIndexDirty = true;
        }
        
        public function get zIndex():int
        {
            return _zIndex;
        }
        
        /**
         * By default, layers are sorted based on the z-index, from small
         * to large.
         * @param value Z-index to set.
         */
        public function set zIndex(value:int):void
        {
            if (_zIndex == value)
                return;
            
            _zIndex = value;
            _zIndexDirty = true;
        }
        
        public function get registrationPoint():Point
        {
            return _registrationPoint.clone();
        }
        
        /**
         * The registration point can be used to offset the sprite
         * so that rotation and scaling work properly.
         *
         * @param value Position of the "center" of the sprite.
         */
        public function set registrationPoint(value:Point):void
        {
            var intX:int = int(value.x);
            var intY:int = int(value.y);
            
            if (intX == _registrationPoint.x && intY == _registrationPoint.y)
                return;
            
            _registrationPoint.x = intX;
            _registrationPoint.y = intY;
            _transformDirty = true;
        }
        
        public function get scale():Point
        {
            return _scale.clone();
        }
        
        /**
         * You can scale things on the X and Y axes.
         */
        public function set scale(value:Point):void
        {
            if (value.x == _scale.x && value.y == _scale.y)
                return;
            
            _scale.x = value.x;
            _scale.y = value.y;
            _transformDirty = true;
        }
        
        /**
         * Explicitly set the size. This overrides scale if it is set.
         */
        public function set size(value:Point):void
        {
            if(!value)
            {
                _size = null;
                return;
            }
            
            if(!_size)
                _size = new Point();
            
            _size.x = value.x;
            _size.y = value.y;
            _transformDirty = true;
        }
        
        public function get size():Point
        {
            if(!_size)
                return _size;
            return _size.clone();
        }
        
        public function get rotation():Number
        {
            return _rotation;
        }
        
        /**
         * Rotation in degrees, with 0 being Y+.
         */
        public function set rotation(value:Number):void
        {
            if (value == _rotation)
                return;
            
            _rotation = value;
            _transformDirty = true;
        }
        
        public function get alpha():Number
        {
            return _alpha;
        }
        
        /**
         * Transparency, 0 being completely transparent and 1 being opaque.
         */
        public function set alpha(value:Number):void
        {
            if (value == _alpha)
                return;
            
            _alpha = value;
            _transformDirty = true;
        }
		
		public function get blendMode():String
		{
			return _blendMode;
		}

		/**
		 * Blend mode, using strings from flash.display.BlendMode
		 * 
		 * @see flash.display.BlendMode
		 */
		public function set blendMode(value:String):void
		{
			if (value == _blendMode)
				return;
			
			// Blend mode values must be lower case, but the enumeration is given in all upper case, which could easily lend itself to confusion.
			value = value.toLowerCase();
			
			// Perform some sanity checks, because setting an incorrect value here can cause a failing exception later
			if ((value != BlendMode.ADD) &&
				(value != BlendMode.ALPHA) &&
				(value != BlendMode.DARKEN) &&
				(value != BlendMode.DIFFERENCE) &&
				(value != BlendMode.ERASE) &&
				(value != BlendMode.HARDLIGHT) &&
				(value != BlendMode.INVERT) &&
				(value != BlendMode.LAYER) &&
				(value != BlendMode.LIGHTEN) &&
				(value != BlendMode.MULTIPLY) &&
				(value != BlendMode.NORMAL) &&
				(value != BlendMode.OVERLAY) &&
				(value != BlendMode.SCREEN) &&
				(value != "shader") && // Only supported in Flex 4.0 and higher
				(value != BlendMode.SUBTRACT))
			{
				Logger.warn(this, "set blendMode", "Could not set the blend mode to '" + value + "', because it is not a valid BlendMode");
				return;
			}
			
			_blendMode = value;
			_transformDirty = true;
		}
		
		public function get positionOffset():Point
		{
			return _positionOffset.clone();
		}
		
		/**
		 * Sets a position offset that will offset the sprite.
		 * 
		 * Please note: This is unaffected by rotation.
		 */
		public function set positionOffset(value:Point):void
		{
			if (value.x == _positionOffset.x && value.y == _positionOffset.y)
				return;
			
			_positionOffset.x = value.x;
			_positionOffset.y = value.y;
			_transformDirty = true;
		}
		
		
        public function get position():Point
        {
            return _position.clone();
        }
        
        /**
         * Position of the renderer in scene space.
         *
         * @see worldPosition
         */
        public function set position(value:Point):void
        {
            var posX:Number;
            var posY:Number;
            
            if (snapToNearestPixels)
            {
                posX = int(value.x);
                posY = int(value.y);
            }
            else
            {
                posX = value.x;
                posY = value.y;
            }
            
            if (posX == _position.x && posY == _position.y)
                return;
            
            _position.x = posX;
            _position.y = posY;
            _transformDirty = true;
        }
        
        /**
         * The x value of our scene space position.
         */
        [EditorData(ignore="true")]
        public function get x():Number
        {
            return _position.x;
        }
        
        public function set x(value:Number):void
        {
            var posX:Number;
            
            if(snapToNearestPixels)
            {
                posX = int(value);
            }
            else
            {
                posX = value;
            }
            
            if (posX == _position.x)
                return;
            
            _position.x = posX;
            _transformDirty = true;
        }
        
        /**
         * The y component of our scene space position. Used for sorting.
         */
        [EditorData(ignore="true")]
        public function get y():Number
        {
            return _position.y;
        }
        
        public function set y(value:Number):void
        {
            var posY:Number;
            
            if(snapToNearestPixels)
            {
                posY = int(value);
            }
            else
            {
                posY = value;
            }
            
            if (posY == _position.y)
                return;
            
            _position.y = posY;
            _transformDirty = true;
        }
        
        /**
         * Convenience method to allow placing the renderer in world coordinates.
         */
        [EditorData(ignore="true")]
        public function set worldPosition(value:Point):void
        {
            removeFromScene();

            if(!scene)
                throw new Error("Not attached to a scene, so cannot transform from world space.");
            
            position = scene.transformWorldToScene(value);
            updateTransform();

            addToScene();
        }
        
        public function get worldPosition():Point
        {
            if(!scene)
                throw new Error("Not attached to a scene, so cannot transform from world space.");

            return scene.transformSceneToWorld(position);
        }
        
        /**
         * Our bounds in scene coordinates.
         */
        [EditorData(ignore="true")]
        public function get sceneBounds():Rectangle
        {
            // NOP if no DO.
            if(!displayObject)
                return null;
            
            var bounds:Rectangle = displayObject.getBounds(displayObject);
            
            // Just translation for now.
            bounds.x += displayObject.x;
            bounds.y += displayObject.y;
            
            // And hand it back.
            return bounds;
        }
        
        /**
         * @return Bounds in object space, relative to its local origin.
         */
        [EditorData(ignore="true")]
        public function get localBounds():Rectangle
        {
            if(!displayObject)
                return null;
            
            return displayObject.getBounds(displayObject);
        }
        
        [EditorData(ignore="true")]
        public function get scene():IScene2D
        {
            return _scene;
        }
        /**
         * The scene which is responsible for drawing this renderer. Note that
         * you can use the renderer outside of a scene, to control some
         * DisplayObject, by setting displayObject to point to what you want
         * to control, and setting scene to null.
         */
        public function set scene(value:IScene2D):void
        {
            // Remove from old scene if appropriate.
            removeFromScene();
            
            _scene = value;
            
            // And add to new scene (clearing dirty state).
            addToScene();
        }
        
        [EditorData(ignore="true")]
        public function get displayObject():DisplayObject
        {
            return _displayObject;
        }
        
        /**
         * The displayObject which this DisplayObjectRenderer will draw.
         */
        public function set displayObject(value:DisplayObject):void
        {
            // Remove old object from scene.
            removeFromScene();
            
            _displayObject = value;
            
            if(name && owner && owner.name)
                _displayObject.name = owner.name + "." + name;
            
            // Add new scene.
            addToScene();
        }
        
        /**
         * Where in the scene will this object be rendered?
         */
        [EditorData(ignore="true")]
        public function get renderPosition():Point
        {
            return new Point(displayObject.x, displayObject.y);
        }
        
        /**
         * Rotation offset applied to the child DisplayObject. Used if, for instance,
         * your art is rotated 90deg off from where you want it.
         *
         * @return Number Offset Rotation angle in degrees
         */
        public function get rotationOffset():Number 
        {
            return PBUtil.getDegreesFromRadians(_rotationOffset);
        }
        
        /**
         * Rotation offset applied to the child DisplayObject.
         *
         * @param value Offset Rotation angle in degrees
         */
        public function set rotationOffset(value:Number):void 
        {
            _rotationOffset = PBUtil.unwrapRadian(PBUtil.getRadiansFromDegrees(value));
        }
        
        /**
         * Transform a point from world space to object space. 
         */
        public function transformWorldToObject(p:Point):Point
        {
            // Oh goodness.
            var tmp:Matrix = _transformMatrix.clone();
            tmp.invert();
            
            return tmp.transformPoint(p);
        }
        
        /**
         * Transform a point from object space to world space. 
         */
        public function transformObjectToWorld(p:Point):Point
        {
            return _transformMatrix.transformPoint(p);            
        }
        
        /**
         * Is the rendered object opaque at the request position in screen space?
         * @param pos Location in world space we are curious about.
         * @return True if object is opaque there.
         */
        public function pointOccupied(worldPosition:Point, mask:ObjectType):Boolean
        {
            if (!displayObject || !scene)
                return false;
            
            // Sanity check.
            if(displayObject.stage == null)
                Logger.warn(this, "pointOccupied", "DisplayObject is not on stage, so hitTestPoint will probably not work right.");
            
            // This is the generic version, which uses hitTestPoint. hitTestPoint
            // takes a coordinate in screen space, so do that.
            worldPosition = scene.transformWorldToScreen(worldPosition);
            return displayObject.hitTestPoint(worldPosition.x, worldPosition.y, true);
        }
        
        override protected function onAdd() : void
        {
            super.onAdd();
			            
            if(_displayObject)
                _displayObject.name = owner.name + "." + name;
            
			addToScene();
			
            // Make sure we start with a correct transform.
            updateTransform(true);
        }
        
        override protected function onRemove() : void
        {
            super.onRemove();
            
            // Remove ourselves from the scene when we are removed.
            removeFromScene();
        }
        
        protected function removeFromScene():void
        {
            if(_scene && _displayObject && _inScene)
            {
                _scene.remove(this);
                _inScene = false;
            }            
        }
        
        protected function addToScene():void
        {
            if(_scene && _displayObject && !_inScene)
            {                
                _scene.add(this);
                _inScene = true;

                _lastLayerIndex = _layerIndex;
                _layerIndexDirty = _zIndexDirty = false;
            }
        }
        
        override public function onFrame(elapsed:Number) : void
        {
            // Lookup and apply properties. This only makes adjustments to the
            // underlying DisplayObject if necessary.
            if (!displayObject)
                return;
            
            updateProperties();
            
            // Now that we've read all our properties, apply them to our transform.
            if (_transformDirty)
                updateTransform();
        }
        
        protected function updateProperties():void
        {
            if(!owner)
                return;
            
            // Sync our zIndex.
            if (zIndexProperty)
                zIndex = owner.getProperty(zIndexProperty, zIndex);
            
            // Sync our layerIndex.
            if (layerIndexProperty)
                layerIndex = owner.getProperty(layerIndexProperty, layerIndex);
            
            // Maybe we were in the right layer, but have the wrong zIndex.
            if (_zIndexDirty && _scene)
            {
                _scene.getLayer(_layerIndex, true).markDirty();
                _zIndexDirty = false;
            }
            
            // Position.
            var pos:Point = owner.getProperty(positionProperty) as Point;
            if (pos)
            {
                if(scene)
                    position = scene.transformWorldToScene(pos);
                else
                    position = pos;
            }
            
            // Scale.
            var scale:Point = owner.getProperty(scaleProperty) as Point;
            if (scale)
            {
                this.scale = scale;
            }
            
            // Size.
            var size:Point = owner.getProperty(sizeProperty) as Point;
            if (size)
            {
                this.size = size;
            }
            
            // Rotation.
            if (rotationProperty)
            {
                var rot:Number = owner.getProperty(rotationProperty) as Number;
                this.rotation = rot;
            }
            
            // Alpha.
            if (alphaProperty)
            {
                var alpha:Number = owner.getProperty(alphaProperty) as Number;
                this.alpha = alpha;
            }

			// Blend Mode.
			if (blendModeProperty)
			{
				var blendMode:String = owner.getProperty(blendModeProperty) as String;
				this.blendMode = blendMode;
			}			
			
            // Registration Point.
            var reg:Point = owner.getProperty(registrationPointProperty) as Point;
            if (reg)
            {
                registrationPoint = reg;
            }
            
            // Make sure we're in the right layer and at the right zIndex in the scene.
            // Do this last to be more caching-layer-friendly. If we change position and
            // layer we can just do this at end and it works.
            if (_layerIndexDirty && _scene)
            {
                var tmp:int = _layerIndex;
                _layerIndex = _lastLayerIndex;
                
                if(_lastLayerIndex != -1)
                    removeFromScene();

                _layerIndex = tmp;
                
                addToScene();
                
                _lastLayerIndex = _layerIndex;
                _layerIndexDirty = false;
            }
        }
        
        /**
         * Update the object's transform based on its current state. Normally
         * called automatically, but in some cases you might have to force it
         * to update immediately.
         * @param updateProps Read fresh values from any mapped properties.
         */
        public function updateTransform(updateProps:Boolean = false):void
        {
            if(!displayObject)
                return;
            
            if(updateProps)
                updateProperties();
            
            // If size is active, it always takes precedence over scale.
            var tmpScaleX:Number = _scale.x;
            var tmpScaleY:Number = _scale.y;
            if(_size)
            {
                var localDimensions:Rectangle = displayObject.getBounds(displayObject);
                tmpScaleX = _scale.x * (_size.x / localDimensions.width);
                tmpScaleY = _scale.y * (_size.y / localDimensions.height);
            }
            
            
            _transformMatrix.identity();
            _transformMatrix.scale(tmpScaleX, tmpScaleY);
            _transformMatrix.translate(-_registrationPoint.x * tmpScaleX, -_registrationPoint.y * tmpScaleY);
            _transformMatrix.rotate(PBUtil.getRadiansFromDegrees(_rotation) + _rotationOffset);
            _transformMatrix.translate(_position.x + _positionOffset.x, _position.y + _positionOffset.y);
            
            displayObject.transform.matrix = _transformMatrix;
            displayObject.alpha = _alpha;
			displayObject.blendMode = _blendMode;
            displayObject.visible = (alpha > 0);
            
            _transformDirty = false;
        }
    }
}