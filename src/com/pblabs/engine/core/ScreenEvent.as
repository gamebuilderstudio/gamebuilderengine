/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.core
{
    import flash.events.Event;

    /**
     * The LevelEvent is used by the LevelManager to dispatch information about the loaded
     * status of levels.
     *
     * @see com.pblabs.engine.core.LevelManager
     */
    public class ScreenEvent extends Event
    {
		/**
		 * This event is dispatched by the ScreenManager right before a screen is shown
		 *
		 * @eventType SCREEN_SHOW
		 */
		public static const SCREEN_SHOW:String = "screenShow";

		/**
		 * This event is dispatched by the ScreenManager right before a screen is hidden
		 *
		 * @eventType SCREEN_HIDE
		 */
		public static const SCREEN_HIDE:String = "screenHide";

		/**
		 * This event is dispatched by the ScreenManager right before a screen is popped or removed from the displayList and cleaned up
		 *
		 * @eventType SCREEN_REMOVE
		 */
		public static const SCREEN_REMOVE:String = "screenRemove";

		/**
		 * The group objects not being unloaded
		 */
		public var screenName : String;

		public function ScreenEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, screenName : String = null)
        {
            this.screenName = screenName;
            super(type, bubbles, cancelable);
        }
		
		override public function clone():Event
		{
			return new ScreenEvent(this.type, this.bubbles, this.cancelable, this.screenName);
		}
    }
	
}

