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