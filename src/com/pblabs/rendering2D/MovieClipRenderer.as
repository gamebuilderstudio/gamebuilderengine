package com.pblabs.rendering2D
{
    import com.pblabs.engine.PBE;
	import com.pblabs.engine.resource.SWFResource;
    
    import flash.display.MovieClip;
	import flash.geom.Point;

    /**
     * Renderer which is for displaying MovieClips/SWFs and playing their
     * animation correctly.
     * 
     * <p>It can be used one of two ways. You can either subclass it and
     * override getClipInstance(), or you create one and set the clip 
     * property.</p>
     */
	public class MovieClipRenderer extends DisplayObjectRenderer
	{
        /**
         * Framerate for playback. 
         */
		public var frameRate:Number = 25;

        /**
         * Should we loop the animation? 
         */
		public var loop:Boolean = false;
		
        /**
         * Should we destroy the entity when animation is over? Useful for
         * things like explosions.
         */
        public var destroyOnEnd:Boolean = false;
        
        protected var _clipFrame:int;
        protected var _clipLastUpdate:Number;
        protected var _clipDirty:Boolean = true;
        protected var _maxFrames:int;
		
		/**
		 * Resource (file)name of the SWFResource 
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
				// Tell the ResourceManager to load the SWFResource
				PBE.resourceManager.load(fileName,SWFResource,swfLoadCompleted,swfLoadFailed,false);				
			}	
		}
		
		public function set clip(value:MovieClip):void
		{
		    if (value === displayObject)
		        return;
		    
		    displayObject = value;
		    _clipDirty = true;
		}
		
		public function get clip():MovieClip
		{
		    return displayObject as MovieClip;
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
		 * Indicates if the SWFResource has been loaded 
		 */ 
		[EditorData(ignore="true")]
		public function get loaded():Boolean
		{
			return _loaded;
		}
		
		/**
		 * Indicates if the SWFResource has failed loading 
		 */
		[EditorData(ignore="true")]
		public function get failed():Boolean
		{
			return _failed;
		}
		
		/**
		 * Loaded SWFResource 
		 */ 
		[EditorData(ignore="true")]
		public function get resource():SWFResource
		{
			return _resource;
		}
		
		protected function getClipInstance():MovieClip
		{
		    return null;
		}
		
		override public function onFrame(elapsed:Number) : void
		{
		    if (!owner)
		        return;
		    
            if (!clip)
                clip = getClipInstance();
                
            if (!clip)
                return;

            if(_clipDirty)
            {
                _clipFrame = 0;
                _clipLastUpdate = 0;
                _maxFrames = findMaxFrames(clip, clip.totalFrames);
                _clipDirty = false;
            }
            
            // Update to next frame when appropriate.
            if(PBE.processManager.virtualTime - _clipLastUpdate > 1000/frameRate)
            {
                // If we're on the last frame, loop or self-destruct.
                if(++_clipFrame > _maxFrames)
                {
                    if (loop) 
                    {
                        _clipFrame = 1;
                    }
                    else 
                    {
                        //Logger.(this, "Finished playback, destroying self.");
                        if(destroyOnEnd)
                            owner.destroy();
                        return;
                    }
                }

                if(clip.totalFrames >= _clipFrame)
                    clip.gotoAndStop(_clipFrame);

                // Update child clips as well.
                updateChildClips(clip, _clipFrame);

                _clipLastUpdate = PBE.processManager.virtualTime;
            }
            
            
            super.onFrame(elapsed);
		}

        /**
         * Find the child clip with the largest number of frames.
         * This will be used as our target for the end of the animation.
         */
        protected function findMaxFrames(parent:MovieClip, currentMax:int):int
        {
            for (var j:int=0; j<parent.numChildren; j++)
            {
                var mc:MovieClip = parent.getChildAt(j) as MovieClip;
                if(!mc)
                    continue;

                currentMax = Math.max(currentMax, mc.totalFrames);            

                findMaxFrames(mc, currentMax);
            }

            return currentMax;
        }

        /**
         * Recursively advance a clip's children to the current frame.
         * This takes into account children with varying frame counts.
         */
        protected function updateChildClips(parent:MovieClip, currentFrame:int):void
        {
            for (var j:int=0; j<parent.numChildren; j++)
            {
                var mc:MovieClip = parent.getChildAt(j) as MovieClip;
                if(!mc)
                    continue;

                if (mc.totalFrames >= currentFrame)
                    mc.gotoAndStop(currentFrame);

                updateChildClips(mc, currentFrame);
            }
        }
		
		//----------------------------------------------------------
		// private methods 
		//----------------------------------------------------------
		
		/**
		 * This function will be called if the SWFResource has been loaded correctly 
		 */ 
		private function swfLoadCompleted(res:SWFResource):void
		{
			_loading = false;
			_loaded = true;
			_resource = res;
			// set the bitmapData of this render object
			clip = res.clip;
			// set the registration (alignment) point to the sprite's center
			registrationPoint = new Point(res.clip.width/2,res.clip.height/2);				
		}
		
		/**
		 * This function will be called if the SWFResource has failed loading 
		 */ 
		private function swfLoadFailed(res:SWFResource):void
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
		private var _resource:SWFResource = null;
	}
}