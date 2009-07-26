package com.pblabs.components.stateMachine
{
   import com.pblabs.engine.entity.*;
   import com.pblabs.engine.core.*;
   import com.pblabs.engine.debug.*;
   
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   
   /**
    * Implementation of IMachine; probably any custom FSM would be based on this.
    *
    * @see IMachine for API docs.
    */
   public class Machine implements IMachine
   {
      /** 
       * Set of states, indexed by name.
       */
      [TypeHint(type="com.pblabs.components.stateMachine.BasicState")]
      public var States:Dictionary = new Dictionary();
      
      /**
       * What state will we start out in?
       */
      public var DefaultState:String = null;
      
      private var _currentState:IState = null;
      private var _PreviousState:IState = null;
      private var _SetNewState:Boolean = false;
      private var _EnteredStateTime:Number = 0;

      private var _propertyBag:IPropertyBag = null;

      /**
       * Virtual time at which we entered the state.
       */
      public function get enteredStateTime():Number
      {
         return _EnteredStateTime;
      }
      
      public function get propertyBag():IPropertyBag
      {
         return _propertyBag;
      }
      
      public function set propertyBag(value:IPropertyBag):void
      {
         _propertyBag = value;
      }
      
      public function tick():void
      {
         _SetNewState = false;
         
         // DefaultState - we get it if no state is set.
         if(!_currentState)
            setCurrentState(DefaultState);
         
         if(_currentState)
            _currentState.tick(this);
         
         // If didn't set a new state, it counts as transitioning to the
         // current state. This updates prev/current state so we can tell
         // if we just transitioned into our current state.
         if(_SetNewState && _currentState)
         {
             _PreviousState = _currentState;
         }
         
         //if(_PreviousState != _currentState)
         //   Logger.print(this, "Transition: " + GetStateName(_PreviousState) + " -> " + GetStateName(_currentState));              
      }
      
      public function getCurrentState():IState
      {
         // DefaultState - we get it if no state is set.
         if(!_currentState)
            setCurrentState(DefaultState);

         return _currentState;
      }
      
      public function get currentState():IState
      {
         return getCurrentState();
      }
      
      public function get currentStateName():String
      {
          return getStateName(getCurrentState());
      }
      
      public function set currentStateName(value:String):void
      {
         setCurrentState(value);
      }
      
      public function getPreviousState():IState
      {
         return _PreviousState;
      }
      
      public function addState(name:String, state:IState):void
      {
          States[name] = state;
      }
      
      public function getState(name:String):IState
      {
         return States[name] as IState;
      }

      public function getStateName(state:IState):String
      {
         for(var name:String in States)
            if(States[name] == state)
                return name;
         
         return null;
      }

      public function setCurrentState(name:String):Boolean
      {
         var newState:IState = getState(name);
         if(!newState)
            return false;
                  
         var oldState:IState = _currentState;
         _SetNewState = true;
         
         _PreviousState = _currentState;
         _currentState = newState;
         
         // Do the right callbacks if we are changing state.
         //if(newState != oldState)
         if(true)
         {
            // Old state gets notified it is changing out.
            if(oldState)
              oldState.exit(this);
             
            // New state finds out it is coming in.    
            newState.enter(this);
            
            // Note the time at which we entered this state.             
            _EnteredStateTime = ProcessManager.instance.virtualTime;
             
            // Fire a transition event, if we have a dispatcher.
            if(_propertyBag)
            {
               var te:TransitionEvent = new TransitionEvent(TransitionEvent.TRANSITION);
               te.oldState = oldState;
               te.oldStateName = getStateName(oldState);
               te.newState = newState;
               te.newStateName = getStateName(newState);
                     
               _propertyBag.eventDispatcher.dispatchEvent(te);
            }
         }
                  
         return true;
      }
      
   }
}
