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
	import avmplus.INCLUDE_METHODS;
	
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.resource.ImageResource;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.textures.Texture;
	
	/**
	 * Render Component that will load and render a ImageResource as a Starling Sprite onto the GPU
	 */ 
	public class SpriteRendererG2D extends BitmapRendererG2D
	{
		//----------------------------------------------------------
		// private and protected variables
		//----------------------------------------------------------
		private var _fileName:String = null;
		private var _loading:Boolean = false;
		private var _loaded:Boolean = false;
		private var _failed:Boolean = false;
		private var _resource:ImageResource = null;
		
		public function SpriteRendererG2D()
		{
			super();
			_smoothing = false;
		}

		override protected function buildG2DObject():void
		{
			if(!Starling.context){
				InitializationUtilG2D.initializeRenderers.add(buildG2DObject);
				return;
			}
			
			if(!this.bitmap || !this.bitmap.bitmapData)
				return;
			
			if(!resource){
				super.buildG2DObject();
				return;
			}
			var texture : Texture = ResourceTextureManagerG2D.getTextureForResource(resource);
			if(!gpuObject){
				if(texture){
					gpuObject = new Image(texture);
				}else{
					texture = ResourceTextureManagerG2D.getTextureForResource(resource);
					if(!texture)
						return;
					gpuObject = new Image( texture );
				}
			}else{
				if((gpuObject as Image).texture)
					(gpuObject as Image).texture.dispose();
				
				if(texture){
					(gpuObject as Image).texture = texture;
				}else{
					(gpuObject as Image).texture = ResourceTextureManagerG2D.getTextureForResource(resource);
				}
				( gpuObject as Image).readjustSize();
			}
			
			smoothing = _smoothing;
			if(gpuObject){
				updateTransform(true);
				
				if(!_initialized){
					addToScene()
					_initialized = true;
				}
			}
			//super.buildG2DObject();
		}
		
		//----------------------------------------------------------
		// private methods 
		//----------------------------------------------------------
		
		protected override function onAdd():void
		{
			super.onAdd();
			if (!_resource && fileName!=null && fileName!="" && !loading)
			{
				_loading = true;
				// Tell the ResourceManager to load the ImageResource
				PBE.resourceManager.load(fileName,ImageResource,imageLoadCompleted,imageLoadFailed,false);				
			}
		}
		
		protected override function onRemove():void
		{
			if (_resource)
			{
				//PBE.resourceManager.unload(_resource.filename, ImageResource);
				_resource = null;
				_loaded = false;
			}   
			
			super.onRemove();

			InitializationUtilG2D.initializeRenderers.remove(buildG2DObject);
		}
		
		/**
		 * This function will be called if the ImageResource has failed loading 
		 */ 
		private function imageLoadFailed(res:ImageResource):void
		{
			_loading = false;
			_failed = true;					
		}
		
		/**
		 * This function will be called if the ImageResource has been loaded correctly 
		 */ 
		private function imageLoadCompleted(res:ImageResource):void
		{
			if(_resource) return;
			
			_loading = false;
			_loaded = true;
			_failed = false;
			_resource = res;
			// set the registration (alignment) point to the sprite's center
			//if(registrationPoint.x == 0 && registrationPoint.y == 0)
			//registrationPoint = new Point(res.image.bitmapData.width/2,res.image.bitmapData.height/2);				
			// set the bitmapData of this render object
			bitmapData = res.image.bitmapData;	
		}
		
		//----------------------------------------------------------
		// public getter/setter functions 
		//----------------------------------------------------------
		
		/**
		 * Resource (file)name of the ImageResource 
		 */ 
		public function get fileName():String
		{
			return _fileName;
		}
		
		public function set fileName(value:String):void
		{
			if (fileName!=value)
			{
				if (_resource)
				{
					//PBE.resourceManager.unload(_resource.filename, ImageResource);
					_resource = null;
				}            
				_fileName = value;
				if(_fileName){
					_loading = true;
					// Tell the ResourceManager to load the ImageResource
					var resource : ImageResource = PBE.resourceManager.load(fileName,ImageResource,imageLoadCompleted,imageLoadFailed,false) as ImageResource;	
					if(resource && resource.bitmapData)
						imageLoadCompleted(resource);
				}else{
					_loading = false;
					_failed = true;
					_resource = null;
					if(bitmapData)
						bitmapData = null;
				}
			}	
		}
		
		/**
		 * Indicates if the resource loading is in progress
		 */ 
		[EditorData(ignore="true")]
		public function get loading():Boolean
		{
			return _loading;
		}
		
		/**
		 * Indicates if the ImageResource has been loaded 
		 */ 
		[EditorData(ignore="true")]
		public function get loaded():Boolean
		{
			return _loaded;
		}
		
		/**
		 * Indicates if the ImageResource has failed loading 
		 */
		[EditorData(ignore="true")]
		public function get failed():Boolean
		{
			return _failed;
		}
		
		/**
		 * Loaded ImageResource 
		 */ 
		[EditorData(ignore="true")]
		public function get resource():ImageResource
		{
			return _resource;
		}
	}
}