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
				_fileName = value;
				_loading = true;
				// Tell the ResourceManager to load the IMageResource
				PBE.resourceManager.load(fileName,ImageResource,imageLoadCompleted,imageLoadFailed,false);				
			}	
		}
		
   	    /**
        * Indicates if the resource is beeing loaded 
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
			_resource = res;
			// set the bitmapData of this render object
			bitmapData = res.image.bitmapData;	
			// set the registration (alignment) point to the sprite's center
			registrationPoint = new Point(res.image.width/2,res.image.height/2);				
		}

   	    /**
        * This function will be called if the ImageResource has failed loading 
        */ 
		private function imageLoadFailed(res:ImageResource):void
		{
			_loading = false;
			_failed = true;					
		}

		//----------------------------------------------------------
		// private and protected variables
		//----------------------------------------------------------
		private var _fileName:String;
		private var _loading:Boolean = false;
		private var _loaded:Boolean = false;
		private var _failed:Boolean = false;
		private var _resource:ImageResource = null;
				
	}
}