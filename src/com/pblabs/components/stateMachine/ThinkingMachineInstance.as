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
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.components.ThinkingComponent;
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.engine.entity.EntityComponent;
    import com.pblabs.engine.entity.IPropertyBag;
    
    /**
     * A state machine which shares its description with other machines. 
     * 
     * Useful when you have many identical FSMs and don't want to pay memory/initialization
     * overhead for each one. Use Machine if you want a one-off FSM.
     */
    public class ThinkingMachineInstance extends ThinkingComponent implements IMachine
    {
        public var description:MachineDescription;
        
        private var _currentState:IState = null;
        private var _previousState:IState = null;
        private var _setNewState:Boolean = false;
        private var _enteredStateTime:Number = 0;
        
        private var _propertyBag:IPropertyBag = null;
        
        public function addState(name:String, state:IState):void
        {
            throw new Error("Not implemented as machine description is shared.");
        }
        
        public function getState(name:String):IState
        {
            return description.getState(name);
        }
        
        public function getStateName(state:IState):String
        {
            return description.getStateName(state);
        }
        
        /**
         * Virtual time at which we entered the state.
         */
        public function get enteredStateTime():Number
        {
            return _enteredStateTime;
        }
        
        public function set enteredStateTime(value:Number):void
        {
            // Update the value and reschedule based on new time.
            _enteredStateTime = value;
            
            if(_currentState is BasicThinkingState)
            {
                var targetDuration:int = (_currentState as BasicThinkingState).getDuration(this);
                think(tick, targetDuration - (PBE.processManager.virtualTime - _enteredStateTime));
            }
        }
        
        /**
         * Time remaining before the state is due to advance.
         */
        public function get timeRemaining():Number
        {
            if(!(_currentState is BasicThinkingState))
                return 0;

            return (_currentState as BasicThinkingState).getDuration(this) - (PBE.processManager.virtualTime - enteredStateTime);
        }
        
        public function get propertyBag():IPropertyBag
        {
            return owner;
        }
        
        public function set propertyBag(value:IPropertyBag):void
        {
            throw new Error("Hardcoded");
        }
        
        public function tick():void
        {
            _setNewState = false;
            
            // DefaultState - we get it if no state is set.
            if(!_currentState)
                setCurrentState(description.defaultState);
            
            if(_currentState)
            {
                // Only tick if it is due to tick.
                if(timeRemaining <= 0)
                    _currentState.tick(this);
            }
            
            //Logger.print(this, "Ticked, now in " + getStateName(_currentState) + " from " + getStateName(_previousState) + "! duration=" + (PBE.processManager.virtualTime - _nextThinkTime));

            // If didn't set a new state, it counts as transitioning to the
            // current state. This updates prev/current state so we can tell
            // if we just transitioned into our current state.
            if(_setNewState == false && _currentState)
            {
                _previousState = _currentState;
            }
        }
        
        public function getCurrentState():IState
        {
            // DefaultState - we get it if no state is set.
            if(!_currentState)
                setCurrentState(description.defaultState);
            
            return _currentState;
        }
        
        public function get currentState():IState
        {
            return getCurrentState();
        }
        
        public function get currentStateName():String
        {
            return description.getStateName(getCurrentState());
        }
        
        public function set currentStateName(value:String):void
        {
            if(!setCurrentState(value))
                Logger.warn(this, "set currentStateName", "Could not transition to state '" + value + "'");
        }
        
        public function getPreviousState():IState
        {
            return _previousState;
        }
        
        public function setCurrentState(name:String):Boolean
        {
            var newState:IState = description.getState(name);
            if(!newState)
                return false;
            
            var oldState:IState = _currentState;
            _setNewState = true;
            
            _previousState = _currentState;
            _currentState = newState;
            
            // Old state gets notified it is changing out.
            if(oldState)
                oldState.exit(this);
            
            // New state finds out it is coming in.    
            newState.enter(this);
            
            // Note the time at which we entered this state.
            _enteredStateTime = PBE.processManager.virtualTime;

            // Schedule next update.
            //Logger.print(this, "Scheduling for now +" + (newState as BasicThinkingState).getDuration(this));
            var targetDuration:int = (newState as BasicThinkingState).getDuration(this);
            if(targetDuration > 0)
                think(tick, targetDuration);
            
            return true;
        }
    }
}