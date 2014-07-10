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
    import com.pblabs.rendering2D.spritesheet.SpriteContainerComponent;

    /**
     * Information describing an animation, for use in an AnimationController.
     *
     * @see AnimationController.
     */
    public final class AnimationControllerInfo
    {
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------

        /**
         * Name of event to fire on the entity when this animation starts.
         */
        public var completeEvent:String;

        /**
         * If true, then the animation loops.
         */
        public var loop:Boolean = true;

        /**
         * The animation playback speed may be affected by many factors; this
         * sets a maximum time period in ms for a frame to be displayed.
         */
        public var maxFrameDelay:Number = 1000;

        /**
         * The desired framerate for this animation. It is overidden by the
         * duration properties on the controller, and maxFrameDelay may 
         * interfere with it.
         */
        public var frameRate:Number = 30;
        
        /**
         * Used when setting animation states; a higher priority
         * animation will override a lower priority animation.
         */
        public var priority:Number = 0.0;
        
        /**
         * Sprite sheet containing this animation.
         */
        public var spriteSheet:SpriteContainerComponent;

        /**
         * Name of event to fire on the entity when this animation starts.
         */
        public var startEvent:String;
		
		/**
		 * A flag to tell the controller to grab custom frames for its internal curFrame property.
		 * This is useful if you have one sprite sheet and just want to grab specific frames.
		 */
		public var customFrames:Boolean = false;

		/**
		 * The list of custom frames to pull from in order
		 */
		public var customFrameList:Array;

		public function getFrameByIndex(index : int):int
		{
			if(!customFrames) return index;
			if(!spriteSheet || !customFrameList || customFrameList.length < 1) return 0;
			return customFrameList[index];
		}
		
		public function get frameCount():int
		{
			if(customFrameList)
			{
				return customFrameList.length;
			}
			if(!spriteSheet) 
				return 0;
			return spriteSheet.frameCount;
		}
    }
}
