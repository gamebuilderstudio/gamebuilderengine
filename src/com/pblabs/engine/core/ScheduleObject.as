package com.pblabs.engine.core
{
    /**
     * Helper class for internal use by ProcessManager. This is used to 
     * track scheduled callbacks from schedule().
     */
    internal final class ScheduleObject implements IPrioritizable
    {
        public var dueTime:Number = 0.0;
        public var thisObject:Object = null;
        public var callback:Function = null;
        public var arguments:Array = null;
        
        public function get priority():int
        {
            return -dueTime;
        }
        
        public function set priority(value:int):void
        {
            throw new Error("Unimplemented.");
        }
    }
}