/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.components.stateMachine
{
    import com.pblabs.engine.components.TickedComponent;
    
    /**
     * Component that wraps a state machine and updates it based on game ticks.
     */
    public class FSMComponent extends TickedComponent
    {
        /**
         * The actual state machine. This is Machine to avoid requiring the
         * user to always specify which FSM they want (since there is only
         * one).
         */ 
        public var stateMachine:Machine;
        
        /**
         * If true, don't advance state machine logic.
         */
        public var paused:Boolean = false;
        
        override protected function onAdd():void
        {
            super.onAdd();
            
            if(stateMachine)
                stateMachine.propertyBag = owner;
        }
        
        override protected function onRemove():void
        {
            super.onRemove();
            
            if(stateMachine)
                stateMachine.propertyBag = null;
        }
        
        override public function onTick(tickRate:Number) : void
        {
            if(paused)
                return;
            
            if(stateMachine)
                stateMachine.tick();
        }
    }
}