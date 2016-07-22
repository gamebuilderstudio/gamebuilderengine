/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2012 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.starling2D
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.PBUtil;
	import com.pblabs.engine.components.AnimatedComponent;
	import com.pblabs.engine.core.ObjectType;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.rendering2D.Camera;
	import com.pblabs.rendering2D.DisplayObjectRenderer;
	import com.pblabs.rendering2D.ICachingLayer;
	import com.pblabs.rendering2D.IDisplayObjectSceneLayer;
	import com.pblabs.rendering2D.ILayerMouseHandler;
	import com.pblabs.rendering2D.SceneAlignment;
	import com.pblabs.rendering2D.ui.IUITarget;
	
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	
	public class DisplayObjectSceneG2D extends AnimatedComponent implements ISceneG2D
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
		public var maxZoom:Number = 3;
		
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
		 * If set, the scene will follow the exact position of the trackedObject
		 * It will also account for the offset position.
		 */
		public var trackByOffset:Boolean = true;

		/**
		 * If set, every frame, trackObject's position is read and assigned
		 * to the scene's position, so that the scene follows the trackObject.
		 */
		public var trackObject:DisplayObjectRendererG2D;
		
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
		
		protected var _sceneAlignment:SceneAlignment = SceneAlignment.TOP_LEFT;
		protected var _lastPos : Point;
		protected var _trackDifPoint : Point = new Point();
		protected var _layerIndex : int = -1;
		
		protected var _camera : StarlingCamera;
		protected var _deadZoneEnabled : Boolean = false;
		protected var _zoomEnabled : Boolean = false;
		protected var _rotationEnabled : Boolean = false;
		
		public function DisplayObjectSceneG2D()
		{
			// Get ticked after all the renderers.
			updatePriority = -10;
			_rootSprite = generateRootSprite();
			ignoreTimeScale = true;
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
			
			if(_camera)
				_camera.destroy();
			_camera = null;
			// Make sure we don't leave any lingering content.
			if(_sceneView && _rootSprite)
				_sceneView.removeDisplayObject(_rootSprite);
			
			_rootSprite.removeChildren(0);
			_rootSprite.dispose();
		}
		
		public function get layerCount():int
		{
			return _layers.length;
		}
		
		public function getLayer(index:int, allocateIfAbsent:Boolean = false):IDisplayObjectSceneLayer
		{
			// Maybe it already exists.
			if(_layers[index])
				return _layers[index];
			
			if(allocateIfAbsent == false)
				return null;
			
			// Return new layer.
			return expandLayersToLayerIndex(index) as IDisplayObjectSceneLayer;
		}
		
		public function invalidate(dirtyRenderer:DisplayObjectRenderer):void
		{
			var layerToDirty:IDisplayObjectSceneLayer = getLayer(dirtyRenderer.layerIndex);
			if(!layerToDirty)
				return;
			
			if(layerToDirty is ICachingLayer)
				ICachingLayer(layerToDirty).invalidate(dirtyRenderer);
		}
		
		public function invalidateRectangle(dirty:Rectangle):void
		{
			for each(var l:DisplayObjectSceneLayerG2D in _layers)
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
			s.touchable = false;
			//TODO: set any properties we want for our root host sprite
			s.name = "DisplayObjectSceneG2DRoot";
			return s;
		}
		
		/**
		 * Convenience funtion for subclasses to control what class of layer
		 * they are using.
		 */
		protected function generateLayer(layerIndex:int):DisplayObjectSceneLayerG2D
		{
			var outLayer:DisplayObjectSceneLayerG2D;
			
			// Go with default.
			if (!outLayer)
				outLayer = new DisplayObjectSceneLayerG2D();
			
			//TODO: set any properties we want for our layer.
			outLayer.name = "Layer" + layerIndex;
			
			return outLayer;
		}
		
		public function get sceneView():IUITarget
		{
			if(!_sceneView && _sceneViewName)
				sceneView = SceneViewG2D.findStarlingView(_sceneViewName) as IUITarget;
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
				_sceneViewName = _sceneView["name"];
				if(_layerIndex == -1)
					_sceneView.addDisplayObject(_rootSprite);
				else
					_sceneView.setDisplayObjectIndex(_rootSprite, _layerIndex);
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
			if(!sceneView || !_camera)
				return null;
			
			// Make sure we are up to date with latest track.
			evaluateTrackedObject();
			
			updateTransform();
			
			_sceneViewBoundsCache.x = _camera.camProxy.x; 
			_sceneViewBoundsCache.y = _camera.camProxy.y;
			_sceneViewBoundsCache.width = sceneView.width / _camera.camProxy.scale;
			_sceneViewBoundsCache.height = sceneView.height / _camera.camProxy.scale;
			
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
			var renderer : DisplayObjectRendererG2D = dor as DisplayObjectRendererG2D;
			// Add to the appropriate layer.
			var layer:IDisplayObjectSceneLayer = getLayer(renderer.layerIndex, true);
			layer.add(dor);
			if (renderer.displayObjectG2D)
				_renderers[renderer.displayObjectG2D] = dor;
		}
		
		public function remove(dor:DisplayObjectRenderer):void
		{
			var renderer : DisplayObjectRendererG2D = dor as DisplayObjectRendererG2D;
			var layer:IDisplayObjectSceneLayer = getLayer(renderer.layerIndex, false);
			if(!layer)
				return;
			
			layer.remove(dor);
			if (renderer.displayObjectG2D)
				delete _renderers[renderer.displayObjectG2D];
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
		
		/**
		 * Takes the global flash stage position and transforms it into coordinates relative to the 2D GPU scene taking the viewport
		 * into account.
		 */
		public function transformScreenToG2DWorld(globalPos:Point):Point
		{
			if(sceneView && sceneView is SceneViewG2D){
				// move position into viewport bounds
				var starlingInstance : Starling = (sceneView as SceneViewG2D).starlingInstance;
				if(starlingInstance){
					globalPos.x = starlingInstance.stage.stageWidth  * (globalPos.x - starlingInstance.viewPort.x) / starlingInstance.viewPort.width;
					globalPos.y = starlingInstance.stage.stageHeight * (globalPos.y - starlingInstance.viewPort.y) / starlingInstance.viewPort.height;
				}
			}
			return globalPos;
		}
		
		/**
		 * Takes the global stage position and transforms it into coordinates relative to the scene
		 */
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
				var renderer:DisplayObjectRendererG2D = getRendererForDisplayObject(o);
				
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
			for each(var l:DisplayObjectSceneLayerG2D in _layers)
			{
				// Skip them if they don't use the interface.
				if(!(l is ILayerMouseHandler))
					continue;
				
				(l as ILayerMouseHandler).getRenderersUnderPoint(scenePosition, mask, results);
			}
			
			return results.length > 0 ? true : false;
		}
		
		public function getRendererForDisplayObject(displayObject:DisplayObject):DisplayObjectRendererG2D
		{
			var current:DisplayObject = displayObject;
			
			// Walk up the display tree looking for a DO we know about.
			while (current)
			{
				// See if it's a DOR.
				var renderer:DisplayObjectRendererG2D = _renderers[current] as DisplayObjectRendererG2D;
				if (renderer)
					return renderer;
				
				// If we get to a layer, we know we're done.
				if(renderer is DisplayObjectSceneLayerG2D)
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

			if(!_camera){
				// Update our transform, if required
				_rootSprite.x = _rootPosition.x;
				_rootSprite.y = _rootPosition.y;
				_rootSprite.scaleX = _rootSprite.scaleY = zoom;
				// Apply rotation.
				_rootSprite.rotation = _rootRotation;
				// Center it appropriately.
				SceneAlignment.calculate(_tempPoint, sceneAlignment, sceneView.width, sceneView.height);
				_rootSprite.x += _tempPoint.x;
				_rootSprite.y += _tempPoint.y;
			}
			
			_transformDirty = false;
		}
		
		public override function onFrame(elapsed:Number) : void
		{
			if(!sceneView)
			{
				Logger.warn(this, "onFrame", "sceneView is null, so we aren't rendering."); 
				return;
			}
			
			// Update our state based on the tracked object, if any.
			evaluateTrackedObject();
			
			// Make sure transforms are up to date.
			updateTransform();

			// Give layers a chance to sort and update.
			for each(var l:DisplayObjectSceneLayerG2D in _layers)
			l.onRender();
			
		}
		
		private var _cameraPos : Point = new Point();
		protected function evaluateTrackedObject():void
		{
			if(trackObject)
			{
					
				if(!_camera){
					_camera = new StarlingCamera(_rootSprite);
					_camera.setUp(trackObject, trackLimitRectangle, !trackByOffset ? new Point(0,0) : new Point( trackOffset.x / _camera.cameraLensWidth, trackOffset.y / _camera.cameraLensHeight) );
				}
				if(_camera.allowZoom != zoomEnabled) _camera.allowZoom = zoomEnabled;
				if(_camera.allowRotation != rotationEnabled) _camera.allowRotation = rotationEnabled;
				if(trackByOffset){
					_camera.center.setTo(trackOffset.x / _camera.cameraLensWidth, trackOffset.y / _camera.cameraLensHeight);
					if(_camera && _camera.target != trackObject)
						_camera.target = trackObject;
				}else{
					_camera.center.setTo(0,0);
					_camera.manualPosition = trackObject.position;
				}
				if(deadZoneEnabled)
					_camera.deadZone.setTo(0, 0, trackObject.size.x, trackObject.size.y);
				else if(_camera.deadZone.width != 0)
					_camera.deadZone.setEmpty();
				
				_camera.bounds = trackLimitRectangle;
				if(zoomEnabled)
				{
					var tmpZoom : Number = PBUtil.clamp(trackObject.scale.x, minZoom, maxZoom);
					_camera.setZoom( tmpZoom );
				}
				if(rotationEnabled) _camera.setRotation( trackObject.rotation );
				_camera.update();
				
				_cameraPos.setTo(int(_camera.camProxy.x), int(_camera.camProxy.y));
				position = _cameraPos;
				zoom = _camera.camProxy.scale;
				rotation = _camera.camProxy.rotation;
			}else if(!trackObject && _camera){
				_camera.target = null;
			}
		}
		
		protected function expandLayersToLayerIndex (layerIndex:int) : DisplayObjectSceneLayerG2D {
			if (layerIndex < _layers.length) return _layers[layerIndex];
			for(var i : int = _layers.length; i <= layerIndex; i++){
				_layers[i] = generateLayer(_layers.length);
				_rootSprite.addChildAt(_layers[i], i);
			}
			return _layers[layerIndex];
		}

		public function setWorldCenter(pos:Point):void
		{
			if (!sceneView)
				throw new Error("sceneView not yet set. can't center the world.");
			
			position = transformWorldToScreen(pos);
		}
		
		public function screenPan(deltaX:int, deltaY:int):void
		{
			if((deltaX == 0 && deltaY == 0) || !_camera)
				return;
			
			if(!_camera.followTarget)
			{
				_camera.manualPosition.x -= deltaX;
				_camera.manualPosition.y -= deltaY;
			}
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
			
			if (_rootPosition.x == value.x && _rootPosition.y == value.y)
				return;
			
			_rootPosition.x = value.x;
			_rootPosition.y = value.y;
			
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
		
		[EditorData(ignore="true")]
		public function get sceneContainer():Object
		{
			return _rootSprite;
		}
		
		/**
		 * Holds DisplayObjectSceneLayerG2D instances to use for various layers.
		 * That is, if index 3 of layers[] holds an instance of DisplayObjectSceneLayerG2D
		 * or a subclass, then that instance will be used for layer #3.
		 * 
		 * Note this is only considered at layer setup time. Use getLayer() to
		 * get a layer that is being actively used.
		 */
		[EditorData(ignore="true")]
		public function get layers():Array
		{
			return _layers;
		}

		/**
		 * The position that this scene should be added to the scene view
		 **/
		public function get layerIndex():int { return _layerIndex; }
		public function set layerIndex(val : int):void {
			_layerIndex = val;
			if(_sceneView){
				sceneView = _sceneView;
			}
		}
		
		[EditorData(ignore="true")]
		public function get camera():Camera{ 
			if(!_camera)
				_camera = new StarlingCamera(_rootSprite);
			return _camera; 
		}

		/**
		 * The center area of the camera that determines which region the camera will allow the tracked object to move without tracking it.
		 **/
		public function get deadZoneEnabled():Boolean { return _deadZoneEnabled; }
		public function set deadZoneEnabled(val : Boolean):void {
			_deadZoneEnabled = val;
		}

		/**
		 * The zoom on/off flag to enable the zooming of this scene.
		 **/
		public function get zoomEnabled():Boolean { return _zoomEnabled; }
		public function set zoomEnabled(val : Boolean):void {
			_zoomEnabled = val;
		}

		/**
		 * The rotation on/off flag to enable the rotation of this scene.
		 **/
		public function get rotationEnabled():Boolean { return _rotationEnabled; }
		public function set rotationEnabled(val : Boolean):void {
			_rotationEnabled = val;
		}

		public function sortSpatials(array:Array):void
		{
			// Subclasses can set how things are sorted.
		}
	}
}