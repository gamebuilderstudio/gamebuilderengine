package com.pblabs.components.stateMachine
{
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.entity.PropertyReference;

    public class BasicThinkingState extends BasicState implements IThinkingState
    {
        public var durationProperty:PropertyReference;
        protected var _duration:int = 0;

        public function set duration(value:int):void
        {
            _duration = value;
        }
        
        public function getDuration(fsm:IMachine):int
        {
            if(durationProperty)
               return fsm.propertyBag.getProperty(durationProperty);             
            return _duration;
        }
        
        public function getTimeForNextTick(fsm:IMachine):int
        {
            return PBE.processManager.virtualTime + getDuration(fsm);
        }
    }
}