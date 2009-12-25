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
    /**
     * An object which will be called back at a specific time. This interface
     * contains all the storage needed for the queueing which the ProcessManager
     * performs, so that the queue has zero memory allocation overhead. 
     * 
     * @see ThinkingComponent
     */
    public interface IQueuedObject extends IPrioritizable
    {
        /**
         * Time (in milliseconds) at which to process this object.
         */
        function get nextThinkTime():Number;
        
        /**
         * Callback to call at the nextThinkTime.
         */
        function get nextThinkCallback():Function;
    }
}