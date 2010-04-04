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
    
    import flash.display.MovieClip;

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
	}
}