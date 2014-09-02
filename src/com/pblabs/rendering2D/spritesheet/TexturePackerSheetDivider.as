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
    import com.pblabs.engine.entity.IEntityComponent;
    import com.pblabs.engine.resource.JSONResource;
    import com.pblabs.engine.resource.ResourceEvent;
    import com.pblabs.rendering2D.spritesheet.ISpriteSheet;
    
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;
    
    /**
     * Divide a spritesheet into cells based on the rect coordinates in the loaded Texture Packer Json-Array 
	 * JSONResource data.
     */
    public class TexturePackerSheetDivider implements ISpriteSheetNamedFramesDivider
    {
		private var _frames : Vector.<CoordinateDataVO>;

		private static var _frameCache : Dictionary = new Dictionary();
		/**
		 * Grab the frame area rectangle by the filename.
		 */
		public function getFrameByName(name:String):Rectangle
		{
			if (!name)
				throw new Error("Name can not be null");
			
			//Strip any file extension from name
			name = removeFileExtension(name);

			if(!_frames || _frames.length < 1)
			{
				if(resource && resource.isLoaded)
				{
					buildFrames();
				}else{
					return null;
				}
			}
			var frameIndex : int = getFrameIndexByName(name);
			return frameIndex >= 0 ? _frames[frameIndex].frameBounds : null;
		}

		/**
		 * @inheritDoc
		 */
		public function getFrameArea(index:int):Rectangle
		{
			if(!_frames || _frames.length < 1)
			{
				if(resource && resource.isLoaded && resource.jsonData)
				{
					buildFrames();
					return getFrameArea(index);
				}
				return new Rectangle(0, 0, 1, 1);
			}
			
			return _frames[index].frameBounds;
		}
		
		/**
		 * Grab the file name of the frame or image that was packed into the sheet.
		 * You can also include file extension in the name returned
		 */
		public function getFrameNameByIndex(index:int, includeFileExtension : Boolean = false):String
		{
			if(!_frames || _frames.length < 1)
			{
				return null;
			}
			
			return includeFileExtension ? _resource.jsonData.frames[index].filename : _frames[index].name;
		}

		public function getFrameIndexByName(name : String):int
		{
			//Strip any file extension from name
			name = removeFileExtension(name);
			var len : int = _frames.length;
			for(var i : int = 0; i < len; i++)
			{
				if(_frames[i].name == name)
					return i;
			}
			return -1;
		}

		protected function buildFrames():void
		{
			if(!_resource){
				return;
			}
			if(_resource && !_resource.isLoaded){
				if(!_resource.hasEventListener(ResourceEvent.LOADED_EVENT))
					_resource.addEventListener(ResourceEvent.LOADED_EVENT, onResourceReady);
				return;
			}
			
			if(_resource.filename in _frameCache){
				_frames = _frameCache[_resource.filename];
			}else{
			
				if(!_frames) 
					_frames = new Vector.<CoordinateDataVO>();
				else
					_frames.length = 0;
				
				//Building list of rectangles that point to frames
				var objectData : Array = _resource.jsonData.frames;
				var dataLen : int = objectData.length;
				for(var i : int = 0; i < dataLen; i++)
				{
					var frameData : Object = objectData[i];
					_frames.push( new CoordinateDataVO(removeFileExtension(frameData.filename), new Rectangle( frameData.frame.x, frameData.frame.y, frameData.frame.w, frameData.frame.h),
						new Point(frameData.sourceSize.w, frameData.sourceSize.h),
						new Rectangle(frameData.spriteSourceSize.x, frameData.spriteSourceSize.y, frameData.spriteSourceSize.w, frameData.spriteSourceSize.h),
						frameData.rotated,
						frameData.trimmed, i) );
				}
				_frameCache[_resource.filename] = _frames;
			}
		}
		
		protected function onResourceReady(resoure : ResourceEvent):void
		{
			buildFrames();
			if(_owningSheet)
				_owningSheet.divider = this;
			_resource.removeEventListener(ResourceEvent.LOADED_EVENT, onResourceReady);
			_resource.addEventListener(ResourceEvent.UPDATED_EVENT, onResourceUpdated);
		}
		
		protected function onResourceUpdated(resoure : ResourceEvent):void
		{
			delete _frameCache[_resource.filename];
			_frames = null;
			buildFrames();
			if(_owningSheet && _owningSheet is IEntityComponent && (_owningSheet as IEntityComponent).owner){
				if(_owningSheet.cached)
					_owningSheet.releaseCache(false);
				_owningSheet.divider = this;
				(_owningSheet as IEntityComponent).owner.reset();
			}
		}
		
		private function removeFileExtension(val : String):String
		{
			//Strip any file extension from name
			if(val.indexOf(".", -1) != -1)
				val = val.split(".")[0];
			return val;
		}

		/**
         * @inheritDoc
         */
        [EditorData(ignore="true")]
		public function get owningSheet():ISpriteSheet{ return _owningSheet; }
        public function set owningSheet(value:ISpriteSheet):void
        {
            _owningSheet = value;
        }
        
        /**
         * @inheritDoc
         */
        public function get frameCount():int
        {
			if(!_frames || !_resource) return 0;
            return _frames.length;
        }
        
		/**
		 * The resource that holds the json data with frame coordinates
		 */
		private var _resource:JSONResource;
		public function get resource():JSONResource { return _resource; }
		public function set resource(obj : JSONResource):void { 
			if(_resource)
				_resource.removeEventListener(ResourceEvent.UPDATED_EVENT, onResourceUpdated);
			_resource = obj; 
			if(_resource){
				_resource.addEventListener(ResourceEvent.UPDATED_EVENT, onResourceUpdated);
				buildFrames();
			}
		}
		
		public function isLoaded():Boolean
		{
			return _resource ? _resource.isLoaded : false;
		}

		/**
         * @inheritDoc
         */
        public function clone():ISpriteSheetDivider
        {
            var c:TexturePackerSheetDivider = new TexturePackerSheetDivider();
            c.resource = resource;
            return c;
        }
		
		/**
		 * @inheritDoc
		 */
		public function copy(divider : ISpriteSheetDivider):ISpriteSheetDivider
		{
			if(divider is TexturePackerSheetDivider){
				(divider as TexturePackerSheetDivider).resource = resource;
				return divider;
			}
			return null;
		}

		/**
		 * @inheritDoc
		 */
		public function destroy():void
		{
			_owningSheet = null;
			if(_resource)
				_resource.removeEventListener(ResourceEvent.UPDATED_EVENT, onResourceUpdated);
			_resource = null;
			_frames = null;
		}

        
        private var _owningSheet:ISpriteSheet;
    }
}
import flash.geom.Point;
import flash.geom.Rectangle;

final class CoordinateDataVO
{
	public var name : String;
	public var frameBounds:Rectangle;
	public var originalFrameSize:Point;
	public var originalFrameTrimmedBounds:Rectangle;
	public var rotated:Boolean;
	public var trimmed:Boolean;
	public var index:int;
	
	public function CoordinateDataVO(name : String, frameBounds:Rectangle, originalFrameSize:Point, originalFrameTrimmedBounds:Rectangle, rotated:Boolean, trimmed:Boolean, index : int):void
	{
		if(name.indexOf("."))
			name = name.split(".")[0];
		this.name = name;
		this.frameBounds = frameBounds;
		this.originalFrameSize = originalFrameSize;
		this.originalFrameTrimmedBounds = originalFrameTrimmedBounds;
		this.rotated = rotated;
		this.trimmed = trimmed;
		this.index = index;
	}
}