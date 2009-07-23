package com.pblabs.components.stateMachine
{
   import com.pblabs.engine.entity.IPropertyBag;

   /**
    * Base interface for a finite state machine.
    */
   public interface IMachine
   {
      /**
       * Update the state machine. The current state is given the opportunity
       * to transition to another state.
       */
      function Tick():void;
      
      /**
       * Register a state under a name.
       */
      function AddState(name:String, state:IState):void;
      
      /**
       * What state are we on this tick?
       */
      function GetCurrentState():IState;
      
      /**
       * What state were we on on the previous tick?
       */
      function GetPreviousState():IState;
      
      /**
       * Get the state registered under the provided name.
       */
      function GetState(name:String):IState;
      
      /**
       * If this state is registered with us, give back the name it is under.
       */
      function GetStateName(state:IState):String;
      
      /**
       * Update the FSM to be in a new state. Current/previous states
       * are updated accordingly, and callbacks and events are dispatched.
       */
      function SetCurrentState(name:String):Boolean;

      /**
       * Property bag, if any, related to this state machine.
       */
      function get PropertyBag():IPropertyBag;
      function set PropertyBag(v:IPropertyBag):void;
   }
}