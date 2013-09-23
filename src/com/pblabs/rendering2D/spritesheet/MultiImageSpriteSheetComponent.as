/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2012 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.rendering2D.spritesheet
{
    import com.pblabs.engine.PBUtil;
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.engine.resource.ImageResource;
    import com.pblabs.engine.resource.ResourceEvent;
    import com.pblabs.rendering2D.spritesheet.ISpriteSheet;
    import com.pblabs.starling2D.spritesheet.SpriteContainerComponentG2D;
    
    import flash.display.BitmapData;
    import flash.geom.Rectangle;
    
    /**
     * Handles loading multiple individual images to make a runtime spritesheet object for rendering.
     * 
     * <p>Pass an array of image reources or data to make up frames in a sheet</p>
     * 
     * <p>Because we may group them in different ways, we distinguish between
     * "raw frames" and a "frame" which might be made up of multiple directions.</p>
     * 
     * <p>On the subject of sprite sheet order: the order is derived from the array</p>
     * 
     * <p>Be aware that Flash implements an upper limit on image size - going over
     * 2048 pixels in any dimension will lead to problems.</p>
     */ 
    public class MultiImageSpriteSheetComponent extends SpriteContainerComponentG2D implements ISpriteSheet
    {
						
		public function get isDestroyed():Boolean{ return _destroyed; }

		/**
		 * When cached is set to true (the default) the rasterized frames
		 * are re-used by all instances of the SpriteSheetComponent
		 * with the same filename.
		 */
		public function get cached():Boolean { return false; }
		public function set cached(val : Boolean):void{
			Logger.warn(this, "cached", "Caching is not supported with a MultiImageSpriteSheetComponent")
		}

		/**
		 * Indicates if the ImageResource loading is in progress 
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
		 * The image resource to use for this sprite sheet.
		 */
		public function get images():Vector.<ImageResource>
		{
			return _images;
		}
		
		/**
		 * @private
		 */
		public function set images(value : Vector.<ImageResource>):void
		{
			if(!value)
				return;
			
			_imageFilename = "";
			var len : int = value.length;
			var loaded : Boolean = len > 0 ? true : false;
			for(var i : int = 0; i < len; i++)
			{
				if(!value[i].isLoaded){
					loaded = false;
					value[i].addEventListener(ResourceEvent.LOADED_EVENT, onResourceLoaded);
					_loading = true;
				}
				_imageFilename +=  value[i].filename + "|";
			}
			_loaded = loaded;
			_failed = false;
			_images = value;
			deleteFrames();
			if(_images && _images.length > 0)
				buildFrames();
		}
		
		/**
         * True if the image data associated with this sprite sheet has been loaded.
         */
        public override function get isLoaded():Boolean
        {
            return _loaded;
        }
        
        /**
         * The bitmap data of the loaded image.
         */
		[EditorData(ignore="true")]
        public function get imageData():BitmapData
        {
			return null;
        }
		public function set imageData(data : BitmapData):void
		{
			//Not Implemented
			Logger.warn(this, "set imageData", "The imageData property is not supported on a MultiImageSpriteSheet");
		}
        
        /**
         * The divider to use to chop up the sprite sheet into frames. If the divider
         * isn't set, the image will be treated as one whole frame.
         */
        [TypeHint(type="dynamic")]
		[EditorData(ignore="true")]
        public function get divider():ISpriteSheetDivider
        {
            return null;
        }
		/**
		 * @private
		 */
		public function set divider(value:ISpriteSheetDivider):void
		{
			//Not Implemented
			Logger.warn(this, "set divider", "The divider property is not supported on a MultiImageSpriteSheet");
		}
		
        
		/**
		 * The bounds of the largest frame in the spritesheet
		 */
		public function get bounds():Rectangle
		{
			return new Rectangle(_bounds.x, _bounds.y, _bounds.width, _bounds.height);
		}

		
        protected override function getSourceFrames() : Array
        {
            // If user provided their own bitmapdatas, return those.
            if(_forcedBitmaps)
                return _forcedBitmaps;
            
            // image isn't loaded, can't do anything yet
            if (!_loaded)
                return null;
            
			var _frames:Array = new Array(_images);
			var tmpBounds : Rectangle;
			var len : int = _images.length;
			for (var i:int = 0; i < len; i++)
			{
				var resource:ImageResource = _images[i];										
				_frames[i] = resource.bitmapData;
				tmpBounds = new Rectangle(0,0,_frames[i].width, _frames[i].height);
				if(!_bounds){
					_bounds = tmpBounds;
				}else{
					var difX : Number = PBUtil.clamp( tmpBounds.width - _bounds.width, 0, 99999999);
					var difY : Number = PBUtil.clamp( tmpBounds.height - _bounds.height, 0, 99999999);
					_bounds.inflate(difX, difY);
				}
				
			}				
            return _frames;
        }
        
        /**
         * From an array of BitmapDatas, initialize the sprite sheet, ignoring
         * divider + filename.
         */
        public function initializeFromBitmapDataArray(bitmaps:Array):void
        {
			//TODO: Add Caching Handling Herer
            _forcedBitmaps = bitmaps;
			if(bitmaps && bitmaps.length > 0)
				_loaded = true;
			else
				_loaded = false;
        }
		
		public function releaseCache(checkReferenceCount:Boolean=true):void
		{
			// TODO Auto Generated method stub
			
		}
		
		/**
		 * destory provides a mechanism to cleans up this component externally if not added to an 
		 * entity or internally when the onRemove method is called.
		 **/
		public function destroy():void
		{
			if(_destroyed) return;
			
			var len : int;
			if(_forcedBitmaps){
				len = _forcedBitmaps.length;
				for(var i : int = 0; i < len; i++){
					//We don't clean up the bitmaps in the forced bitmaps array 
					//because the bitmaps were created elsewhere
					_forcedBitmaps.pop();
				}
				_forcedBitmaps = null;
			}
			this.deleteFrames();
			
			_bounds = null;
			if (_images)
			{
				_images = null;
				_loaded = false;
			}  
			
			_destroyed = true;
		}
		
		protected function onImageLoaded(resource:ImageResource):void
		{
			var loaded : Boolean = true;
			var len : int = _images.length;
			for(var i : int = 0; i < len; i++)
			{
				if(!_images[i].isLoaded){
					loaded = false;
				}
			}
			if(loaded)
				_loading = false;
			_loaded = loaded;
			if(_loaded){
				deleteFrames();
				buildFrames();
			}
		}
		
		protected function onImageFailed(resource:ImageResource):void
		{
			_loading = false;
			_failed = true;
			Logger.error(this, "onImageFailed", "Failed to load '" + (resource ? resource.filename : "(unknown)") + "'");
		}
		
		override protected function onAdd():void
		{
			super.onAdd();
			_destroyed = false;
		}
		
		override protected function onRemove():void
		{
			destroy();
			super.onRemove();         			
		}
		
		protected function onResourceLoaded(event : ResourceEvent):void
		{
			onImageLoaded(event.resourceObject as ImageResource);
		}
		protected function onResourceLoadFailed(event : ResourceEvent):void
		{
			onImageFailed(event.resourceObject as ImageResource);
		}
		
		protected var _imageFilename:String = null;
		protected var _images:Vector.<ImageResource> = null;
		protected var _loading:Boolean = false;
		protected var _loaded:Boolean = false;
		protected var _failed:Boolean = false;
		protected var _imageData:BitmapData = null;
		protected var _bounds:Rectangle;
		protected var _forcedBitmaps:Array = null;
		protected var _destroyed:Boolean = false;
		protected var _cached:Boolean = true;
    }
}