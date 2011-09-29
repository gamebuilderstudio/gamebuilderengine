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
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.resource.ResourceEvent;
	import com.pblabs.engine.resource.SWFResource;
	import com.pblabs.engine.util.MCUtil;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/**
	 * Render Component that will load and render a SWFResource to a bitmap
	 */ 
	public class SWFSpriteRenderer extends BitmapRenderer
	{
		private var _resource:SWFResource = null;
		private var _classInstance:DisplayObject = null;
		private var _origSize : Point;

		public function SWFSpriteRenderer()
		{
			super();
		}
		
		/**
		 * This function will be called if the SWFResource has been loaded
		 */ 
		protected function onResourceLoaded(resource:SWFResource):void
		{
			if(_resource) return;
			
			if(!containingObjectName) {
				var swfClass : Class;
				if(resource.appDomain)
				{
					swfClass = resource.appDomain.getDefinition( getQualifiedClassName(resource.clip) ) as Class;
				}else{
					swfClass = getDefinitionByName( getQualifiedClassName(resource.clip) ) as Class;
				}
				paintDisplayObjectToBitmap( new swfClass() );
				//Logger.error(this, 'resourceContent', 'A SWF resource requires that the containingObjectName be populated');
			}else if(resource.appDomain){
				paintDisplayObjectToBitmap( resource.getExportedAsset(_containingObjectName) as DisplayObject );
			}else{
				Logger.error(this, 'onResourceLoaded', 'The SWF resource is missing domain information, so it can not be extracted.');
			}
			
			_loaded = true;
			_resource = resource;
			_fileName = _resource.filename;
		}
		
		/**
		 * This function will be called if the SWFResource has failed loading 
		 */ 
		protected function onResourceLoadFailed(resource:SWFResource):void
		{
			Logger.error(this, 'onResourceLoadFailed', 'The SWF resource failed to load!');
			_loaded = false;
			_failed = true;					
		}
		
		protected function paintDisplayObjectToBitmap(instance : DisplayObject):void
		{
			if(!instance) return;
			
			var localDimensions:Rectangle = instance.getBounds(instance);
			if(!_classInstance || _classInstance != instance)
			{
				_origSize = localDimensions.size;
			}
			_classInstance = instance;
			MCUtil.stopMovieClips( _classInstance as MovieClip);
			// set the registration (alignment) point to the sprite's center
			if(!_registrationPoint || _registrationPoint.x == 0 && _registrationPoint.y == 0){
				_registrationPoint = MCUtil.getRegistrationPoint( _classInstance );
				if(_registrationPoint.x < 0) _registrationPoint.x *= -1;
				if(_registrationPoint.y < 0) _registrationPoint.y *= -1;
			}
			
			var m : Matrix = new Matrix();
			m.scale(tmpScale.x, tmpScale.y);
			m.translate(-localDimensions.topLeft.x * tmpScale.x, -localDimensions.topLeft.y * tmpScale.y);
			var swfBitmapData : BitmapData = new BitmapData(Math.max(1, Math.min(2880, (_origSize.x*tmpScale.x))), Math.max(1, Math.min(2880,(_origSize.y*tmpScale.y))), true, 0x000000);
			swfBitmapData.draw(_classInstance, m, _classInstance.transform.colorTransform, _classInstance.blendMode );
			// set the bitmapData of this render object
			bitmapData = swfBitmapData;	
		}

		protected override function onAdd():void
		{
			super.onAdd();
			if (!_resource && fileName!=null && fileName!="" && !_loaded)
			{
				// Tell the ResourceManager to load the ImageResource
				PBE.resourceManager.load(fileName,SWFResource,onResourceLoaded,onResourceLoadFailed,false);
			}
		}

		/*protected override function onRemove():void
		{
			if (_resource)
			{
				_resource.removeEventListener(ResourceEvent.LOADED_EVENT,
			}   
			
			super.onRemove();
		}*/
		
		override public function updateTransform(updateProps:Boolean = false):void
		{
			if(!displayObject)
				return;
			
			if(updateProps)
				updateProperties();
			
			_transformMatrix.identity();
			//_transformMatrix.scale(tmpScale.x, tmpScale.y);
			_transformMatrix.translate(-_registrationPoint.x * tmpScale.x, -_registrationPoint.y * tmpScale.y);
			_transformMatrix.rotate(PBUtil.getRadiansFromDegrees(_rotation) + _rotationOffset);
			_transformMatrix.translate(_position.x + _positionOffset.x, _position.y + _positionOffset.y);
			
			displayObject.transform.matrix = _transformMatrix;
			displayObject.alpha = _alpha;
			displayObject.blendMode = _blendMode;
			displayObject.visible = (alpha > 0);
			
			_transformDirty = false;
		}

		private var _tmpScale : Point = new Point();
		public function get tmpScale():Point{ 
			var tmpScaleX:Number = _scale.x;
			var tmpScaleY:Number = _scale.y;
			if(_size && (_size.x > 0 || _size.y > 0))
			{
				tmpScaleX = _scale.x * (_size.x / _origSize.x);
				tmpScaleY = _scale.y * (_size.y / _origSize.y);
			}
			_tmpScale.x = tmpScaleX;
			_tmpScale.y = tmpScaleY;
			return _tmpScale;
		}

		override public function set size(value:Point):void
		{
			super.size = value;
			if(_classInstance)
				paintDisplayObjectToBitmap(_classInstance);
		}

		override public function set scale(value:Point):void
		{
			super.scale = value;
			if(_classInstance)
				paintDisplayObjectToBitmap(_classInstance);
		}

		protected var _containingObjectName : String;
		public function get containingObjectName():String { return _containingObjectName; }
		public function set containingObjectName(name : String):void
		{
			_containingObjectName = name;
		}

		private var _failed : Boolean = false;
		public function get failed(): Boolean{ return _failed; }

		private var _loaded : Boolean = false;
		public function get loaded(): Boolean{ return _loaded; }

		/**
		 * pointer to the loaded SWFResource 
		 */ 
		public function get swfResource():SWFResource { return _resource; }
		public function set swfResource(resource : SWFResource):void
		{
			if(!resource.isLoaded)
			{
				//This is possibly a memory leak
				resource.addEventListener(ResourceEvent.LOADED_EVENT, function (event:Event):void { onResourceLoaded(resource); } );
				resource.addEventListener(ResourceEvent.FAILED_EVENT, function (event:Event):void { onResourceLoadFailed(resource); } );
				return;
			}
			
			onResourceLoaded( resource );
		}

		private var _fileName:String = null;
		/**
		 * Resource (file)name of the SWFResource 
		 */ 
		public function get fileName():String{ return _fileName; }
		public function set fileName(value:String):void
		{
			if (fileName!=value)
			{
				if (_resource)
				{
					_resource = null;
				}            
				_fileName = value;
				// Tell the ResourceManager to load the ImageResource
				var resource : SWFResource = PBE.resourceManager.load(fileName,SWFResource,onResourceLoaded,onResourceLoadFailed,false) as SWFResource;	
				if(resource && resource.isLoaded)
					onResourceLoaded(resource);
			}	
		}
	}
}