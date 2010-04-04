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
    import com.pblabs.engine.entity.EntityComponent;
    
    import flash.utils.Dictionary;
    
    public class MachineDescription extends EntityComponent
    {
        /** 
         * Set of states, indexed by name.
         */
        [TypeHint(type="com.pblabs.components.stateMachine.BasicState")]
        public var states:Dictionary = new Dictionary();
        
        /**
         * What state will we start out in?
         */
        public var defaultState:String = null;

        
        public function addState(name:String, state:IState):void
        {
            states[name] = state;
        }
        
        public function getState(name:String):IState
        {
            return states[name] as IState;
        }
        
        public function getStateName(state:IState):String
        {
            for(var name:String in states)
                if(states[name] == state)
                    return name;
            
            return null;
        }
    }
}