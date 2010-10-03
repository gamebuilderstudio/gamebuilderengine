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
    import com.pblabs.rendering2D.ui.IUITarget;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.*;
    import flash.utils.Dictionary;
    
    /**
     * Basic Rendering2D scene; it is given a SceneView and some 
     * DisplayObjectRenderers, and makes sure that they are drawn. Extensible
     * for more complex rendering scenarios. Enforces sorting order, too.
     */
    public class DisplayObjectScene extends AnimatedComponent implements IScene2D
    {
        /**
         * Minimum allowed zoom level.
         * 
         * @see zoom 
         */
        public var minZoom:Number = .01;
        
        /**
         * Maximum allowed zoom level.
         * 
         * @see zoom 
         */
        public var maxZoom:Number = 1;
        
        /**
         * How the scene is aligned relative to its position property.
         * 
         * @see SceneAlignment
         * @see position 
         */
        public function set sceneAlignment(value:SceneAlignment):void
        {
			if (value != _sceneAlignment)
			{
            	_sceneAlignment = value;
            	_transformDirty = true;
				updateTransform();
			}
        }

        /**
         * @private
         */ 
        public function get sceneAlignment():SceneAlignment
        {
            return _sceneAlignment;
        }
        
        /**
         * Holds DisplayObjectSceneLayer instances to use for various layers.
         * That is, if index 3 of layers[] holds an instance of DisplayObjectSceneLayer
         * or a subclass, then that instance will be used for layer #3.
         * 
         * Note this is only considered at layer setup time. Use getLayer() to
         * get a layer that is being actively used.
         */
        public var layers:Array = [];
        
        /**
         * If set, every frame, trackObject's position is read and assigned
         * to the scene's position, so that the scene follows the trackObject.
         */
        public var trackObject:DisplayObjectRenderer;
        
        /**
         * An x/y offset for adjusting the camera's focus around the tracked
         * object.
         * 
         * Only applies if trackObject is set.
         */ 
        public var trackOffset:Point = new Point(0,0);
        
        protected var _sceneView:IUITarget;
        protected var _sceneViewName:String = null;
        protected var _rootSprite:Sprite;
        protected var _layers:Array = [];
        protected var _renderers:Dictionary = new Dictionary(true);
        
        protected var _zoom:Number = 1;
        protected var _rootPosition:Point = new Point();
        protected var _rootRotation:Number = 0;
        protected var _rootTransform:Matrix = new Matrix();
        protected var _transformDirty:Boolean = true;
        protected var _currentWorldCenter:Point = new Point();

        protected var _sceneViewBoundsCache:Rectangle = new Rectangle();
        protected var _tempPoint:Point = new Point();
        
        protected var _trackLimitRectangle:Rectangle = null;

        protected var _sceneAlignment:SceneAlignment = SceneAlignment.DEFAULT_ALIGNMENT;

        public function DisplayObjectScene()
        {
            // Get ticked after all the renderers.
            updatePriority = -10;
            _rootSprite = generateRootSprite();
        }
        
        protected override function onAdd() : void
        {
            super.onAdd();
            
            // Make sure we start with a correct transform.
            _transformDirty = true;
            updateTransform();
        }
        
        protected override function onRemove() : void
        {
            super.onRemove();
            
            // Make sure we don't leave any lingering content.
            if(_sceneView)
                _sceneView.removeDisplayObject(_rootSprite);
        }
        
        public function get layerCount():int
        {
            return _layers.length;
        }
        
        public function getLayer(index:int, allocateIfAbsent:Boolean = false):DisplayObjectSceneLayer
        {
            // Maybe it already exists.
            if(_layers[index])
                return _layers[index];
            
            if(allocateIfAbsent == false)
                return null;
            
            // Allocate the layer.
             _layers[index] = generateLayer(index);
                        
            // Order the layers. This is suboptimal but we are probably not going
            // to be adding a lot of layers all the time.
            while(_rootSprite.numChildren)
                _rootSprite.removeChildAt(_rootSprite.numChildren-1);
            for(var i:int=0; i<layerCount; i++)
            {
                if (_layers[i])
                    _rootSprite.addChild(_layers[i]);
            }
            
            // Return new layer.
            return _layers[index];
        }
        
        public function invalidate(dirtyRenderer:DisplayObjectRenderer):void
        {
            var layerToDirty:DisplayObjectSceneLayer = getLayer(dirtyRenderer.layerIndex);
            if(!layerToDirty)
                return;
            
            if(layerToDirty is ICachingLayer)
                ICachingLayer(layerToDirty).invalidate(dirtyRenderer);
        }
        
        public function invalidateRectangle(dirty:Rectangle):void
        {
            for each(var l:DisplayObjectSceneLayer in _layers)
            {
                if(l is ICachingLayer)
                    (l as ICachingLayer).invalidateRectangle(dirty);
            }            
        }
        
        /**
         * Convenience function for subclasses to create a custom root sprite. 
         */
        protected function generateRootSprite():Sprite
        {
            var s:Sprite = new Sprite();
            
            //TODO: set any properties we want for our root host sprite
            s.name = "DisplayObjectSceneRoot";
            
            return s;
        }
        
        /**
         * Convenience funtion for subclasses to control what class of layer
         * they are using.
         */
        protected function generateLayer(layerIndex:int):DisplayObjectSceneLayer
        {
            var outLayer:DisplayObjectSceneLayer;
            
            // Do we have that layer already specified?
            if (layers && layers[layerIndex])
                outLayer = layers[layerIndex] as DisplayObjectSceneLayer;

            // Go with default.
            if (!outLayer)
                outLayer = new DisplayObjectSceneLayer();

            //TODO: set any properties we want for our layer.
            outLayer.name = "Layer" + layerIndex;
            
            return outLayer;
        }
        
        public function get sceneView():IUITarget
        {
            if(!_sceneView && _sceneViewName)
                sceneView = PBE.findChild(_sceneViewName) as IUITarget;
            
            return _sceneView;
        }
        
        /**
         * The IUITarget to which we will be displaying the scene. A scene can
         * only draw to on IUITarget at a time.
         */
        [EditorData(ignore="true")]
        public function set sceneView(value:IUITarget):void
        {
            if(_sceneView)
            {
                _sceneView.removeDisplayObject(_rootSprite);
            }
            
            _sceneView = value;
            
            if(_sceneView)
            {
                _sceneView.addDisplayObject(_rootSprite);
            }
        }
        
        public function get sceneViewName():String
        {
            return _sceneViewName;
        }
        
        public function set sceneViewName(value:String):void
        {
            _sceneViewName = value;
        }
        
        public function get sceneViewBounds():Rectangle
        {
            if(!sceneView)
                return null;

            // Make sure we are up to date with latest track.
            if(trackObject)
            {
                position = new Point(-(trackObject.position.x + trackOffset.x), 
                                     -(trackObject.position.y + trackOffset.y));
            }
            
            if(trackLimitRectangle != null)
            {
            	var centeredLimitBounds:Rectangle = new Rectangle( trackLimitRectangle.x     + (sceneView.width * 0.5) / zoom, trackLimitRectangle.y      + (sceneView.height * 0.5) / zoom,
            	                                                   trackLimitRectangle.width - (sceneView.width / zoom)      , trackLimitRectangle.height - (sceneView.height/zoom) );
                
				
                position = new Point(PBUtil.clamp(position.x, -centeredLimitBounds.right, -centeredLimitBounds.left ), 
                                     PBUtil.clamp(position.y, -centeredLimitBounds.bottom, -centeredLimitBounds.top) );
            }

            updateTransform();

            // What region of the scene are we currently viewing?
            SceneAlignment.calculate(_tempPoint, sceneAlignment, sceneView.width / zoom, sceneView.height / zoom);
            
            _sceneViewBoundsCache.x = -position.x - _tempPoint.x; 
            _sceneViewBoundsCache.y = -position.y - _tempPoint.y;
            _sceneViewBoundsCache.width = sceneView.width / zoom;
            _sceneViewBoundsCache.height = sceneView.height / zoom;
            
            return _sceneViewBoundsCache;
        }
        
        protected function sceneViewResized(event:Event) : void
        {
            _transformDirty = true;
        }
        
        /**
         * @inheritDoc
         */
        public function get trackLimitRectangle():Rectangle
        {
            return _trackLimitRectangle;
        }
        
        /**
         * @inheritDoc
         */
        public function set trackLimitRectangle(value:Rectangle):void
        {
            _trackLimitRectangle = value;
        }
        
        
        public function add(dor:DisplayObjectRenderer):void
        {
            // Add to the appropriate layer.
            var layer:DisplayObjectSceneLayer = getLayer(dor.layerIndex, true);
            layer.add(dor);
            if (dor.displayObject)
                _renderers[dor.displayObject] = dor;
        }
        
        public function remove(dor:DisplayObjectRenderer):void
        {
            var layer:DisplayObjectSceneLayer = getLayer(dor.layerIndex, false);
            if(!layer)
                return;

            layer.remove(dor);
            if (dor.displayObject)
                delete _renderers[dor.displayObject];
        }
        
        public function transformWorldToScene(inPos:Point):Point
        {
            return inPos;
        }
        
        public function transformSceneToWorld(inPos:Point):Point
        {
            return inPos;
        }
        
        public function transformSceneToScreen(inPos:Point):Point
        {
            updateTransform();
            return _rootSprite.localToGlobal(inPos);
        }
        
        public function transformScreenToScene(inPos:Point):Point
        {
            updateTransform();
            return _rootSprite.globalToLocal(inPos);
        }
        
        public function transformWorldToScreen(inPos:Point):Point
        {
            updateTransform();
            return _rootSprite.localToGlobal(inPos);            
        }
        
        public function transformScreenToWorld(inPos:Point):Point
        {
            updateTransform();
            return _rootSprite.globalToLocal(inPos);            
        }
        
		public function getRenderersUnderPoint(screenPosition:Point, results:Array, mask:ObjectType = null):Boolean
        {
            // Query normal DO hierarchy.
            var unfilteredResults:Array = _rootSprite.getObjectsUnderPoint(screenPosition);
            var scenePosition:Point = transformScreenToScene(screenPosition);
            
            for each (var o:* in unfilteredResults)
            {
                var renderer:DisplayObjectRenderer = getRendererForDisplayObject(o);
                
                if(!renderer)
                    continue;
                
                if(!renderer.owner)
                    continue;
                
                if(mask && !PBE.objectTypeManager.doTypesOverlap(mask, renderer.objectMask))
                    continue;
                
                if(!renderer.pointOccupied(scenePosition, mask))
                    continue;
                
                results.push(renderer);
            }

            // Also give layers opportunity to return renderers.
            scenePosition = transformScreenToScene(screenPosition);
            for each(var l:DisplayObjectSceneLayer in _layers)
            {
                // Skip them if they don't use the interface.
                if(!(l is ILayerMouseHandler))
                    continue;
                
                (l as ILayerMouseHandler).getRenderersUnderPoint(scenePosition, mask, results);
            }
            
            return results.length > 0 ? true : false;
        }
        
        public function getRendererForDisplayObject(displayObject:DisplayObject):DisplayObjectRenderer
        {
            var current:DisplayObject = displayObject;
            
            // Walk up the display tree looking for a DO we know about.
            while (current)
            {
                // See if it's a DOR.
                var renderer:DisplayObjectRenderer = _renderers[current] as DisplayObjectRenderer;
                if (renderer)
                    return renderer;
                
                // If we get to a layer, we know we're done.
                if(renderer is DisplayObjectSceneLayer)
                    return null;
                
                // Go up the tree..
                current = current.parent;
            }
            
            // No match!
            return null;
        }

        public function updateTransform():void
        {
            if(!sceneView)
                return;
            
            if(_transformDirty == false)
                return;
            _transformDirty = false;

            // Update our transform, if required
            _rootTransform.identity();
            _rootTransform.translate(_rootPosition.x, _rootPosition.y);
            _rootTransform.scale(zoom, zoom);
            
            // Apply rotation.
            _rootTransform.rotate(_rootRotation);

            // Center it appropriately.
            SceneAlignment.calculate(_tempPoint, sceneAlignment, sceneView.width, sceneView.height);
            _rootTransform.translate(_tempPoint.x, _tempPoint.y);

            // Apply the transform.
            _rootSprite.transform.matrix = _rootTransform;
        }
        
        public override function onFrame(elapsed:Number) : void
        {
            if(!sceneView)
            {
                Logger.warn(this, "updateTransform", "sceneView is null, so we aren't rendering."); 
                return;
            }
            
            // Update our state based on the tracked object, if any.
            if(trackObject)
            {
                position = new Point(-(trackObject.position.x + trackOffset.x), 
                                     -(trackObject.position.y + trackOffset.y));
            }
            
            // Apply limit to camera movement.
            if(trackLimitRectangle != null)
            {
            	var centeredLimitBounds:Rectangle = new Rectangle( trackLimitRectangle.x     + sceneView.width * 0.5, trackLimitRectangle.y      + sceneView.height * 0.5,
            	                                                   trackLimitRectangle.width - sceneView.width      , trackLimitRectangle.height - sceneView.height );
                
                position = new Point(PBUtil.clamp(position.x, -centeredLimitBounds.right, -centeredLimitBounds.left ), 
                                     PBUtil.clamp(position.y, -centeredLimitBounds.bottom, -centeredLimitBounds.top) );
            }

            // Make sure transforms are up to date.
            updateTransform();
            
            // This is disabled, because it causes everything in the screen
            // to invalidate and redraw.
            
            //PBE.pushStageQuality(StageQuality.LOW);
            
            // Give layers a chance to sort and update.
            for each(var l:DisplayObjectSceneLayer in _layers)
                l.onRender();

            //PBE.pushStageQuality(StageQuality.HIGH);
        }
                
        public function setWorldCenter(pos:Point):void
        {
            if (!sceneView)
                throw new Error("sceneView not yet set. can't center the world.");
         
            position = transformWorldToScreen(pos);
        }
        
        public function screenPan(deltaX:int, deltaY:int):void
        {
            if(deltaX == 0 && deltaY == 0)
                return;
            
            // TODO: Take into account rotation so it's correct even when
            //       rotating.
            
            _rootPosition.x -= int(deltaX / _zoom);
            _rootPosition.y -= int(deltaY / _zoom);        
            _transformDirty = true;
        }
        
        public function get rotation():Number
        {
            return _rootRotation;
        }
        public function set rotation(value:Number):void
        {
			if (_rootRotation != value)
			{
            	_rootRotation = value;
            	_transformDirty = true;
			}
        }
        
        public function get position():Point
        {
            return _rootPosition.clone();
        }
        
        public function set position(value:Point) : void
        {
            if (!value)
                return;
            						
            var newX:int = int(value.x);
            var newY:int = int(value.y);
            
            if (_rootPosition.x == newX && _rootPosition.y == newY)
                return;
                
            _rootPosition.x = newX;
            _rootPosition.y = newY;
									
			// Apply limit to camera movement.
			if(trackLimitRectangle != null)
			{
				var centeredLimitBounds:Rectangle = new Rectangle( trackLimitRectangle.x     + (sceneView.width * 0.5) / zoom, trackLimitRectangle.y      + (sceneView.height * 0.5) / zoom,
					trackLimitRectangle.width - (sceneView.width / zoom)      , trackLimitRectangle.height - (sceneView.height/zoom) );
				
				_rootPosition.x = PBUtil.clamp(_rootPosition.x, -centeredLimitBounds.right, -centeredLimitBounds.left );
				_rootPosition.y = PBUtil.clamp(_rootPosition.y, -centeredLimitBounds.bottom, -centeredLimitBounds.top);
			}
						
            _transformDirty = true;
        }
        
        public function get zoom():Number
        {
            return _zoom;
        }
        
        public function set zoom(value:Number):void
        {
            // Make sure our zoom level stays within the desired bounds
            value = PBUtil.clamp(value, minZoom, maxZoom);
            
            if (_zoom == value)
                return;
                
            _zoom = value;
            _transformDirty = true;
        }
        
        public function sortSpatials(array:Array):void
        {
            // Subclasses can set how things are sorted.
        }
    }
}