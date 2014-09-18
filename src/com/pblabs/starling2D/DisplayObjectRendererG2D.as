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
	import com.pblabs.engine.PBUtil;
	import com.pblabs.engine.core.ObjectType;
	import com.pblabs.rendering2D.DisplayObjectRenderer;
	import com.pblabs.starling2D.IGPURenderer;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	
	/**
	 * Abstract base renderer for Rendering Starling GPU 2D DisplayObjects. It wraps a starling DisplayObject, allows it
	 * to be controlled by PropertyReferences, and hooks it into a PBE scene.
	 *
	 * <p>The various other renderers like BitmapRendererG2D inherit from DisplayObjectRendererG2D,
	 * and rely on it for basic GPU functionality.</p>
	 *
	 * <p>Normally, the DisplayObjectRendererG2D tries to update itself
	 * every frame. However, you can suppress this by setting
	 * registerForUpdates to false, in which case you will have to
	 * call onFrame()/updateTransform() manually if you change
	 * something.</p>
	 *
	 * @see BitmapRendererG2D
	 * @see DisplayObjectRendererG2D
	 */
	public class DisplayObjectRendererG2D extends DisplayObjectRenderer implements IGPURenderer
	{
		public function DisplayObjectRendererG2D()
		{
			super();
		}
		
		protected var gpuObject : DisplayObject;
		protected var gpuObjectDirty : Boolean = false;
		protected var _mouseEnabled:Boolean = true;
		internal var _initialized : Boolean = false;

		/**
		 * @inheritDoc
		 */
		override public function onFrame(elapsed:Number) : void
		{
			// Lookup and apply properties. This only makes adjustments to the
			// underlying DisplayObject if necessary.
			if (!gpuObject){
				super.onFrame(elapsed);
				return;
			}
			
			updateProperties();
			
			// Now that we've read all our properties, apply them to our transform.
			if (_transformDirty)
				updateTransform();
		}

		/**
		 * @inheritDoc
		 */
		override public function updateTransform(updateProps:Boolean = false):void
		{
			if(!gpuObject){
				super.updateTransform(updateProps);
				return;
			}

			if(updateProps)
				updateProperties();
			
			var tmpScale : Point = combinedScale;
			_transformMatrix.identity();
			_transformMatrix.scale(tmpScale.x, tmpScale.y);
			_transformMatrix.translate(-_registrationPoint.x * tmpScale.x, -_registrationPoint.y * tmpScale.y);
			_transformMatrix.rotate(PBUtil.getRadiansFromDegrees(_rotation) + _rotationOffset);
			_transformMatrix.translate((_position.x + _positionOffset.x), (_position.y + _positionOffset.y));
			
			gpuObject.transformationMatrix = _transformMatrix;
			gpuObject.alpha = this._alpha;
			gpuObject.blendMode = this._blendMode;
			gpuObject.visible = (alpha > 0);
			gpuObject.touchable = _mouseEnabled;

			_transformDirty = false;
		}

		/**
		 * Is the rendered object opaque at the request position in screen space?
		 * @param pos Location in world space we are curious about.
		 * @return True if object is opaque there.
		 */
		override public function pointOccupied(worldPosition:Point, mask:ObjectType):Boolean
		{
			if (!gpuObject || !scene)
				return super.pointOccupied(worldPosition, mask);
			
			var localPos:Point = transformWorldToObject(worldPosition);
			return gpuObject.hitTest(localPos) ? true : false;
		}
		
		override protected function onRemove() : void
		{
			super.onRemove();
			if(gpuObject) {
				if(gpuObject.hasOwnProperty("texture"))
				{
					gpuObject['texture'].dispose();
				}
				if(gpuObject.parent)
					gpuObject.parent.removeChild(gpuObject, true);
			}

			gpuObject = null;
			InitializationUtilG2D.initializeRenderers.remove(buildG2DObject);
		}
		
		override protected function removeFromScene():void
		{
			if(_scene && _inScene && gpuObject)
			{
				_scene.remove(this);
				_inScene = false;
			}else{
				super.removeFromScene();
			}
		}
		
		override protected function addToScene():void
		{
			if(_scene && !_inScene && gpuObject && _layerIndex != -1)
			{                
				updateTransform();
				_scene.add(this);
				_inScene = true;
				
				_lastLayerIndex = _layerIndex;
				_layerIndexDirty = _zIndexDirty = false;
			}else{
				super.addToScene();
			}
		}
		

		protected function buildG2DObject(skipCreation : Boolean = false):void
		{
			if(!Starling.context && !skipCreation){
				InitializationUtilG2D.initializeRenderers.add(buildG2DObject);
				return;
			}
			
			//Subclasses should create gpuObject Here
			//If(!skipCreation){ //Creation Code }
			
			if(gpuObject)
			{
				if(!_initialized){
					addToScene();
					_initialized = true;
				}
			}
			
			updateTransform(true);
		}
		
		public function get displayObjectG2D():DisplayObject
		{
			//Logger.error(this, "gpuDisplayObject", "GPU getter should be overriden by subclass");
			return gpuObject;
		}

		
		/**
		 * @inheritDoc
		 */
		[EditorData(ignore="true")]
		override public function get sceneBounds():Rectangle
		{
			// NOP if no DO.
			if(!gpuObject)
				return super.sceneBounds;
			
			var bounds:Rectangle = gpuObject.getBounds(scene.sceneContainer as DisplayObject);
			
			// And hand it back.
			return bounds;
		}

		/**
		 * @inheritDoc
		 */
		[EditorData(ignore="true")]
		override public function get localBounds():Rectangle
		{
			if(!gpuObject)
				return super.localBounds;
			return gpuObject.getBounds(gpuObject);
		}

		/**
		 * The combined scale that takes into account the size and scale property when calculating scale
		 */
		private var _boundsRec : Rectangle = new Rectangle();
		override public function get combinedScale():Point
		{
			if(!gpuObject)
				return super.combinedScale;
			
			_tmpCombinedScale.x = _scale.x;
			_tmpCombinedScale.y = _scale.y;
			if(_size && (_size.x > 0 || _size.y > 0))
			{
				gpuObject.getBounds(gpuObject, _boundsRec);
				_tmpCombinedScale.x = _scale.x * (_size.x / _boundsRec.width);
				_tmpCombinedScale.y = _scale.y * (_size.y / _boundsRec.height);
			}
			return _tmpCombinedScale;
		}

		/**
		 * @see Starling Sprite.touchable
		 */
		public function set mouseEnabled(value:Boolean):void
		{
			_mouseEnabled = value;
			if(gpuObject)
				gpuObject.touchable = _mouseEnabled;
		}
		
		public function get mouseEnabled():Boolean
		{
			return _mouseEnabled;
		}
	}
}