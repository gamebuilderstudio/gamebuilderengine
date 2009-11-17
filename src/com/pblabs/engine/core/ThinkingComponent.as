package com.pblabs.engine.core
{
    import com.pblabs.engine.entity.EntityComponent;
    
    /**
     * Base class for components which want to use think notifications.
     * 
     * <p>"Think notifications" allow a component to specify a time and
     * callback function which should be called back at that time. In this
     * way you can easily build complex behavior (by changing which callback
     * you pass) which is also efficient (because it is only called when 
     * needed, not every tick/frame). It is also light on the GC because
     * no allocations are required beyond the initial allocation of the
     * ThinkingComponent.</p>
     */
    public class ThinkingComponent extends EntityComponent implements IQueuedObject
    {
        protected var _nextThinkTime:int;
        protected var _nextThinkCallback:Function;
        
        public function think(nextCallback:Function, timeTillThink:int):void
        {
            _nextThinkTime = ProcessManager.instance.virtualTime + timeTillThink;
            _nextThinkCallback = nextCallback;

            ProcessManager.instance.queueObject(this);
        }
        
        public function get nextThinkTime():Number
        {
            return _nextThinkTime;
        }
        
        public function get nextThinkCallback():Function
        {
            return _nextThinkCallback;
        }
        
        public function get priority():int
        {
            return -_nextThinkTime;
        }
        
        public function set priority(value:int):void
        {
            throw new Error("Unimplemented.");
        }
    }
}