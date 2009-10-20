package com.pblabs.rendering2D
{
    import com.pblabs.engine.components.AnimatedComponent;
    import com.pblabs.engine.core.ObjectType;
    import com.pblabs.engine.core.ProcessManager;
    import com.pblabs.engine.entity.PropertyReference;
    import com.pblabs.engine.math.Utility;
    
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
         * If set, scale is gotten from this property every frame. 
         */
        public var scaleProperty:PropertyReference;

        /**
         * If set, rotation is gotten from this property every frame. 
         */
        public var rotationProperty:PropertyReference;
        
        /**
         * If set, alpha is gotten from this property every frame. 
         */
        public var alphaProperty:PropertyReference;
        
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
        
        protected var _registrationPoint:Point = new Point();
        protected var _scale:Point = new Point(1, 1);
        protected var _rotation:Number = 0;
        protected var _alpha:Number = 1;
        protected var _position:Point = new Point();
        
        protected var _transformMatrix:Matrix = new Matrix();

        protected var _transformDirty:Boolean = true;
        protected var _layerIndexDirty:Boolean = true;
        protected var _zIndexDirty:Boolean = true;
        protected var _hitTestDirty:Boolean = true;
        
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
            var intX:int = int(value.x);
            var intY:int = int(value.y);

            if (intX == _position.x && intY == _position.y)
                return;
            
            _position.x = intX;
            _position.y = intY;
            _transformDirty = true;
        }
        
        /**
         * The y component of our scene space position. Used for sorting.
         */
        public function get positionY():Number
        {
            return _position.y;
        }
        
        /**
         * Convenience method to allow placing the renderer in world coordinates. 
         */
        public function set worldPosition(value:Point):void
        {
            scene.remove(this);

            position = scene.transformWorldToScene(value);
            updateTransform();
            
            scene.add(this);
        }
        
        public function get worldPosition():Point
        {
            return scene.transformSceneToWorld(position);
        }
        
        /**
         * Our bounds in scene coordinates.
         */
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
        public function get localBounds():Rectangle
        {
            if(!displayObject)
                return null;
            
            return displayObject.getBounds(displayObject);
        }

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
            if(_scene && _displayObject)
                _scene.remove(this);

            _scene = value;
            
            // And add to new scene (clearing dirty state).
            if(_scene && _displayObject)
            {
                _scene.add(this);
                _lastLayerIndex = _layerIndex;
                _layerIndexDirty = _zIndexDirty = false;
            }
        }
        
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
            if(_scene && _displayObject)
                _scene.remove(this);
            
            _displayObject = value;
            
            // Add new scene.
            if(_scene && _displayObject)
            {
                _scene.add(this);
                _lastLayerIndex = _layerIndex;
                _layerIndexDirty = _zIndexDirty = false;
            }
        }
        
        /**
         * Where in the scene will this object be rendered? 
         */
        public function get renderPosition():Point
        {
            return new Point(displayObject.x, displayObject.y);
        }
        
        /**
         * Is the rendered object opaque at the request position in screen space?
         * @param pos Location in screen space we are curious about.
         * @return True if object is opaque there.
         * 
         */
        public function pointOccupied(pos:Point):Boolean
        {
            if (!displayObject || !scene)
                return false;

            // This is the generic version.
            return displayObject.hitTestPoint(pos.x, pos.y, true);
        }
        
        override protected function onAdd() : void
        {
            super.onAdd();
        }
        
        override protected function onRemove() : void
        {
            super.onRemove();

            // Remove ourself from the scene when we are removed
            if(_scene && _displayObject)
                _scene.remove(this);
            
            _scene.invalidate(this);
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
            // Sync our zIndex.
            if (zIndexProperty)
                zIndex = owner.getProperty(zIndexProperty, zIndex);
            
            // Sync our layerIndex.
            if (layerIndexProperty)
                layerIndex = owner.getProperty(layerIndexProperty, layerIndex);
            
            // Make sure we're in the right layer and at the right zIndex in the scene.
            if (_layerIndexDirty && _scene)
            {
                var tmp:int = _layerIndex;
                _layerIndex = _lastLayerIndex;
                
                if(_lastLayerIndex != -1)
                    _scene.remove(this);
                
                _layerIndex = tmp;
                
                _scene.add(this);
                
                _lastLayerIndex = _layerIndex;
                _layerIndexDirty = false;
            }
            
            // Maybe we were in the right layer, but have the wrong zIndex.
            if (_zIndexDirty && _scene)
            {
                _scene.getLayer(_layerIndex).markDirty();
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
            
            // Registration Point.
            var reg:Point = owner.getProperty(registrationPointProperty) as Point;
            if (reg)
            {
                registrationPoint = reg;
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
            
            _transformMatrix.identity();
            _transformMatrix.scale(_scale.x, _scale.y);
            _transformMatrix.translate(-_registrationPoint.x, -_registrationPoint.y);
            _transformMatrix.rotate(Utility.getRadiansFromDegrees(_rotation));
            _transformMatrix.translate(_position.x , _position.y);
            
            displayObject.transform.matrix = _transformMatrix;
            displayObject.alpha = _alpha;
            displayObject.visible = (alpha > 0);

            _transformDirty = false;
        }
    }
}