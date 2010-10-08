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
    import com.pblabs.engine.resource.ImageResource;
    
    import flash.geom.Point;
	
   /**
    * Render Component that will load and render a ImageResource as a Sprite
    */ 
	public class SpriteRenderer extends BitmapRenderer
	{
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
					PBE.resourceManager.unload(_resource.filename, ImageResource);
					_resource = null;
				}            
				_fileName = value;
				_loading = true;
				// Tell the ResourceManager to load the ImageResource
				PBE.resourceManager.load(fileName,ImageResource,imageLoadCompleted,imageLoadFailed,false);				
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

		//----------------------------------------------------------
		// public methods 
		//----------------------------------------------------------
		
   	    /**
        * Constructor 
        */ 
		public function SpriteRenderer()
		{
			super();
		}
		
		//----------------------------------------------------------
		// private methods 
		//----------------------------------------------------------

   	    /**
        * This function will be called if the ImageResource has been loaded correctly 
        */ 
		private function imageLoadCompleted(res:ImageResource):void
		{
			_loading = false;
			_loaded = true;
			_failed = false;
			_resource = res;
			// set the registration (alignment) point to the sprite's center
			registrationPoint = new Point(res.image.bitmapData.width/2,res.image.bitmapData.height/2);				
			// set the bitmapData of this render object
			bitmapData = res.image.bitmapData;	
		}
		
		protected override function dataModified():void
		{
			// set the registration (alignment) point to the sprite's center
			registrationPoint = new Point(bitmapData.width/2,bitmapData.height/2);							
		}

   	    /**
        * This function will be called if the ImageResource has failed loading 
        */ 
		private function imageLoadFailed(res:ImageResource):void
		{
			_loading = false;
			_failed = true;					
		}
		
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
				PBE.resourceManager.unload(_resource.filename, ImageResource);
				_resource = null;
				_loaded = false;
			}   
			
			super.onRemove();
		}
		
		//----------------------------------------------------------
		// private and protected variables
		//----------------------------------------------------------
		private var _fileName:String = null;
		private var _loading:Boolean = false;
		private var _loaded:Boolean = false;
		private var _failed:Boolean = false;
		private var _resource:ImageResource = null;
				
	}
}