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
	import com.pblabs.engine.core.ObjectType;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.rendering2D.DisplayObjectRenderer;
	import com.pblabs.rendering2D.IScene2D;
	import com.pblabs.starling2D.IGPURenderer;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.utils.deg2rad;
	
	/**
	 * Base renderer for Rendering Starling GPU 2D DisplayObjects. It wraps a starling DisplayObject, allows it
	 * to be controlled by PropertyReferences, and hooks it into a PBE scene.
	 *
	 * <p>The various other renderers like BitmapRenderer inherit from DisplayObjectRendererG2D,
	 * and rely on it for basic GPU functionality.</p>
	 *
	 * <p>Normally, the DisplayObjectRenderer tries to update itself
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
		protected var _mouseEnabled:Boolean = false;
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
			
			gpuObject.pivotX = _registrationPoint.x;
			gpuObject.pivotY = _registrationPoint.y;
			gpuObject.x = this._position.x + _positionOffset.x;
			gpuObject.y = this._position.y + _positionOffset.y;
			gpuObject.rotation = PBUtil.getRadiansFromDegrees(_rotation) + _rotationOffset;
			gpuObject.scaleX = this.combinedScale.x;
			gpuObject.scaleY = this.combinedScale.y;
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
			
			// This is the generic version, which uses hitTestPoint. hitTestPoint
			// takes a coordinate in screen space, so do that.
			worldPosition = scene.transformWorldToScreen(worldPosition);
			
			return gpuObject.hitTest(worldPosition) ? true : false;
		}
		
		override protected function onRemove() : void
		{
			super.onRemove();
			
			if(gpuObject) {
				gpuObject.dispose();
				if(gpuObject.hasOwnProperty("texture"))
				{
					gpuObject['texture'].dispose();
				}
				gpuObject = null;
			}
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
			if(_scene && !_inScene && gpuObject)
			{                
				_scene.add(this);
				_inScene = true;
				
				_lastLayerIndex = _layerIndex;
				_layerIndexDirty = _zIndexDirty = false;
			}else{
				super.addToScene();
			}
		}
		

		protected function buildG2DObject():void
		{
			if(!Starling.context){
				InitializationUtilG2D.initializeRenderers.add(buildG2DObject);
				return;
			}
			
			if(gpuObject)
			{
				if(!_initialized){
					addToScene()
					_initialized = true;
				}
			}
		}
		
		public function get displayObjectG2D():DisplayObject
		{
			//Logger.error(this, "gpuDisplayObject", "GPU getter should be overriden by subclass");
			return gpuObject;
		}

		/**
		 * @inheritDoc
		 */
		override public function set registrationPoint(value:Point):void
		{
			super.registrationPoint = value;
			
			if(!gpuObject) return;
			gpuObject.pivotX = _registrationPoint.x;
			gpuObject.pivotY = _registrationPoint.y;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function set scale(value:Point):void
		{
			super.scale = value;
			if(!gpuObject) return;
			gpuObject.scaleX = this._scale.x;
			gpuObject.scaleY = this._scale.y;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set size(value:Point):void
		{
			super.size = value;
			
			if(!gpuObject) return;
			//gpuObject.width = _size.x;
			//gpuObject.height = _size.y;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set rotation(value:Number):void
		{
			super.rotation = value;

			if(!gpuObject) return;
			gpuObject.rotation = this._rotation;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set alpha(value:Number):void
		{
			super.alpha = value;

			if(!gpuObject) return;
			gpuObject.alpha = this._alpha;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set blendMode(value:String):void
		{
			super.blendMode = value;
			
			if(!gpuObject) return;
			gpuObject.blendMode = this._blendMode;
		}

		/**
		 * @inheritDoc
		 */
		override public function set position(value:Point):void
		{
			super.position = value;
			
			if(!gpuObject) return;
			gpuObject.x = this._position.x + _positionOffset.x;
			gpuObject.y = this._position.y + _positionOffset.y;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set positionOffset(value:Point):void
		{
			super.positionOffset = value;
			
			if(!gpuObject) return;
			gpuObject.x = this._position.x + _positionOffset.x;
			gpuObject.y = this._position.y + _positionOffset.y;
		}

		/**
		 * @inheritDoc
		 */
		override public function set x(value:Number):void
		{
			super.x = value;
			if(!gpuObject) return;
			gpuObject.x = this._position.x + _positionOffset.x;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set y(value:Number):void
		{
			super.y = value;
			if(!gpuObject) return;
			gpuObject.y = this._position.y + _positionOffset.y;
		}

		
		/**
		 * @inheritDoc
		 */
		override public function set rotationOffset(value:Number):void 
		{
			super.rotationOffset = value;
			if(!gpuObject) return;
			gpuObject.rotation = this._rotation + this._rotationOffset;
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
		override public function get combinedScale():Point
		{
			if(!gpuObject)
				return super.combinedScale;
			
			_tmpCombinedScale.x = _scale.x;
			_tmpCombinedScale.y = _scale.y;
			if(_size && (_size.x > 0 || _size.y > 0))
			{
				var localDimensions:Rectangle = displayObjectG2D.getBounds(displayObjectG2D);
				_tmpCombinedScale.x = _scale.x * (_size.x / localDimensions.width);
				_tmpCombinedScale.y = _scale.y * (_size.y / localDimensions.height);
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