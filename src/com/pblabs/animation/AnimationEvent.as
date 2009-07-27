/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.animation
{
    import flash.events.Event;
    /**
     * Event type used by the Animator class to indicate when certain playback events have happened.
     */
    public class AnimationEvent extends Event
    {
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		public function AnimationEvent(type:String, animation:Animator, bubbles:Boolean = true, cancelable:Boolean = false)
		{
			animation = animation;
			super(type, bubbles, cancelable);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
        /**
         * This event is dispatched by an Animator when the animation completely finishes.
         *
         * @eventType ANIMATION_FINISHED_EVENT
         */
        public static const ANIMATION_FINISHED_EVENT:String = "ANIMATION_FINISHED_EVENT";

        /**
         * This event is dispatched by an Animator when the animation has finished one iteration
         * and is repeating.
         *
         * @eventType ANIMATION_REPEATED_EVENT
         */
        public static const ANIMATION_REPEATED_EVENT:String = "ANIMATION_REPEATED_EVENT";

        /**
         * This event is dispatched by an Animator when the animation is resumed after being manually
         * stopped.
         *
         * @eventType ANIMATION_RESUMED_EVENT
         */
        public static const ANIMATION_RESUMED_EVENT:String = "ANIMATION_RESUMED_EVENT";
        /**
         * This event is dispatched by an Animator when the animation first starts.
         *
         * @eventType ANIMATION_STARTED_EVENT
         */
        public static const ANIMATION_STARTED_EVENT:String = "ANIMATION_STARTED_EVENT";

        /**
         * This event is dispatched by an Animator when the animation is manually stopped.
         *
         * @eventType ANIMATION_STOPPED_EVENT
         */
        public static const ANIMATION_STOPPED_EVENT:String = "ANIMATION_STOPPED_EVENT";

        /**
         * The Animator that triggered the event.
         */
        public var animation:Animator = null;
    }
}

