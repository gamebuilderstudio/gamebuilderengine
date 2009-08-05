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
    public class LevelEvent extends Event
    {
        /**
         * This event is dispatched by the LevelManager when it is ready to be used.
         *
         * @eventType READY_EVENT
         */
        public static const READY_EVENT:String = "ready";

        /**
         * This event is dispatched by the LevelManager when a level's data has been loaded.
         *
         * @eventType LEVEL_LOADED_EVENT
         */
        public static const LEVEL_LOADED_EVENT:String = "levelLoaded";

        /**
         * This event is dispatched by the LevelManager when a level's data has been unloaded.
         *
         * @eventType LEVEL_UNLOADED_EVENT
         */
        public static const LEVEL_UNLOADED_EVENT:String = "levelUnloaded";

        /**
         * The level associated with this event.
         */
        public var level:int = -1;

        public function LevelEvent(type:String, level:int, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            this.level = level;
            super(type, bubbles, cancelable);
        }
    }
}

