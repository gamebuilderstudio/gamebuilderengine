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
	import com.pblabs.engine.util.ImageFrameData;
	import com.pblabs.engine.util.MCUtil;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/**
	 * Render Component that will load and render a SWFResource to a bitmap
	 */ 
	public class SWFSpriteRenderer extends BitmapRenderer
	{
		
		protected var _resource:SWFResource = null;
		protected var _classInstance:DisplayObject = null;
		protected var _origSize : Point;
		protected var _parentMC : MovieClip = new MovieClip();

		public function SWFSpriteRenderer()
		{
			super();
		}
		
		protected function onResourceUpdated(event : ResourceEvent):void
		{
			onResourceLoaded(event.resourceObject as SWFResource);
			(this.owner)
				this.owner.reset();
		}
		
		/**
		 * This function will be called if the SWFResource has been loaded
		 */ 
		protected function onResourceLoaded(resource:SWFResource):void
		{
			if(_resource)
				_resource.removeEventListener(ResourceEvent.UPDATED_EVENT, onResourceUpdated);
			
			if(resource.hasEventListener(ResourceEvent.LOADED_EVENT))
				resource.removeEventListener(ResourceEvent.LOADED_EVENT, resourceLoadedHandler );
			if(resource.hasEventListener(ResourceEvent.FAILED_EVENT))
				resource.removeEventListener(ResourceEvent.FAILED_EVENT, resourceFailedLoadingHandler );

			_loaded = true;
			_resource = resource;
			_resource.addEventListener(ResourceEvent.UPDATED_EVENT, onResourceUpdated);
			_fileName = _resource.filename;

			if(!containingObjectName) {
				var swfClass : Class;
				if(_resource.appDomain)
				{
					swfClass = _resource.appDomain.getDefinition( getQualifiedClassName(_resource.clip) ) as Class;
				}else{
					swfClass = getDefinitionByName( getQualifiedClassName(_resource.clip) ) as Class;
				}
				paintMovieClipToBitmap( new swfClass() );
				//Logger.error(this, 'resourceContent', 'A SWF resource requires that the containingObjectName be populated');
			}else if(_resource.appDomain){
				paintMovieClipToBitmap( _resource.getExportedAsset(_containingObjectName) as DisplayObject );
			}else{
				Logger.error(this, 'onResourceLoaded', 'The SWF resource is missing domain information, so it can not be extracted.');
			}
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
		
		protected function paintMovieClipToBitmap(instance : DisplayObject):void
		{
			if(!instance) return;
			
			if(bitmapData){
				bitmapData.dispose();
				bitmapData = null;
			}
			
			//Hack required so that the movie clip animation is drawn correctly
			//Ridiculous Adobe!!!
			if(PBE.mainStage){
				PBE.mainStage.addChild(_parentMC);
				_parentMC.addChild( instance );
			}

			MCUtil.stopMovieClips( instance as MovieClip);

			var localDimensions:Rectangle = MCUtil.getRealBounds(instance);

			//Set original size if this movie clip is new
			if(!_classInstance || _classInstance != instance)
			{
				_origSize = localDimensions.size;
			}
			_classInstance = instance;
			
			// set the registration (alignment) point to the sprite's center
			if(!bitmapData && _registrationPoint.x == 0 && _registrationPoint.y == 0){
				_registrationPoint = MCUtil.getRegistrationPoint( _classInstance );
				if(_registrationPoint.x < 0) _registrationPoint.x *= -1;
				if(_registrationPoint.y < 0) _registrationPoint.y *= -1;
			}
			
			var frameData : ImageFrameData = MCUtil.getBitmapDataByDisplay(instance, scale, instance.transform.colorTransform, localDimensions);

			//Clean up hack
			if(PBE.mainStage){
				PBE.mainStage.removeChild(_parentMC);
				_parentMC.removeChild( instance );
			}

			// set the bitmapData of this render object
			bitmapData = frameData.bitmapData;	
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

		protected override function onRemove():void
		{
			if(_resource){
				if(_resource.hasEventListener(ResourceEvent.LOADED_EVENT))
					_resource.removeEventListener(ResourceEvent.LOADED_EVENT, resourceLoadedHandler );
				if(_resource.hasEventListener(ResourceEvent.FAILED_EVENT))
					_resource.removeEventListener(ResourceEvent.FAILED_EVENT, resourceFailedLoadingHandler );
				_resource.removeEventListener(ResourceEvent.UPDATED_EVENT, onResourceUpdated);
			}
			_resource = null;
			_classInstance = null
			
			super.onRemove();
		}
		
		override public function updateTransform(updateProps:Boolean = false):void
		{
			if(!displayObject)
				return;
			
			if(updateProps)
				updateProperties();
			
			_transformMatrix.identity();
			//_transformMatrix.scale(combinedScale.x, combinedScale.y);
			_transformMatrix.translate(-_registrationPoint.x * combinedScale.x, -_registrationPoint.y * combinedScale.y);
			_transformMatrix.rotate(PBUtil.getRadiansFromDegrees(_rotation) + _rotationOffset);
			_transformMatrix.translate(_position.x + _positionOffset.x, _position.y + _positionOffset.y);
			
			displayObject.transform.matrix = _transformMatrix;
			displayObject.alpha = _alpha;
			displayObject.blendMode = _blendMode;
			displayObject.visible = (alpha > 0);
			
			_transformDirty = false;
		}
		
		private function resourceLoadedHandler(event : ResourceEvent):void
		{
			onResourceLoaded(event.resourceObject as SWFResource);
		}

		private function resourceFailedLoadingHandler(event : ResourceEvent):void
		{
			onResourceLoadFailed(event.resourceObject as SWFResource);
		}

		override public function get combinedScale():Point{ 
			var tmpScaleX:Number = _scale.x;
			var tmpScaleY:Number = _scale.y;
			if(_size && (_size.x > 0 || _size.y > 0))
			{
				tmpScaleX = _scale.x * (_size.x / _origSize.x);
				tmpScaleY = _scale.y * (_size.y / _origSize.y);
			}
			_tmpCombinedScale.x = tmpScaleX;
			_tmpCombinedScale.y = tmpScaleY;
			return _tmpCombinedScale;
		}

		override public function set size(value:Point):void
		{
			var rePaint : Boolean = false;
			if(!_size.equals( value ))
				rePaint = true;
			super.size = value;
			if(_classInstance && rePaint)
				paintMovieClipToBitmap(_classInstance);
		}

		override public function set scale(value:Point):void
		{
			var rePaint : Boolean = false;
			if(!_scale.equals( value ))
				rePaint = true;
			super.scale = value;
			if(_classInstance && rePaint)
				paintMovieClipToBitmap(_classInstance);
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
				resource.addEventListener(ResourceEvent.LOADED_EVENT, resourceLoadedHandler );
				resource.addEventListener(ResourceEvent.FAILED_EVENT, resourceFailedLoadingHandler );
				return;
			}
			
			onResourceLoaded( resource );
		}

		protected var _fileName:String = null;
		/**
		 * Resource (file)name of the SWFResource 
		 */ 
		public function get fileName():String{ return _fileName; }
		public function set fileName(value:String):void
		{
			if (fileName!=value)
			{
				_fileName = value;
				if(_fileName){
					// Tell the ResourceManager to load the ImageResource
					var resource : SWFResource = PBE.resourceManager.load(fileName,SWFResource,onResourceLoaded,onResourceLoadFailed,false) as SWFResource;	
					if(resource && resource.isLoaded)
						onResourceLoaded(resource);
				}else{
					_loaded = false;
					_failed = true;
					if(_resource)
						_resource.removeEventListener(ResourceEvent.UPDATED_EVENT, onResourceUpdated);
					_resource = null;
					_classInstance = null;
					bitmapData = null;
				}
			}	
		}
		
		public function get swf():MovieClip { return _classInstance as MovieClip; }
	}
}