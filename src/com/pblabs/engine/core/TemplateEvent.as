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
     * The TemplateEvent is used by the TemplateManager to dispatch information about the loaded
     * status of groups.
     *
     * @see com.pblabs.engine.core.TemplateManager
     */
    public class TemplateEvent extends Event
    {

        /**
         * This event is dispatched by the TemplateManager when a group's entities have been loaded.
         *
         * @eventType GROUP_LOADED
         */
        public static const GROUP_LOADED:String = "groupLoaded";

        /**
         * The object name associated with this event.
         */
        public var name:String;

        public function TemplateEvent(type:String, name:String, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            this.name = name;
            super(type, bubbles, cancelable);
        }
    }
}

