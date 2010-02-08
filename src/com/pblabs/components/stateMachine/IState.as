package com.pblabs.components.stateMachine
{
   /**
    * A state in a state machine. It is given the opportunity each
    * update of the machine to transition to a new state.
    * 
    * Callbacks happen AFTER the previous/current state has been updated.
    */
   public interface IState
   {
      /**
       * Called when the machine enters this state.
       */
      function enter(fsm:IMachine):void;
      
      /**
       * Called every time the machine ticks and this is the current state.
       * 
       * Typically this function will call setCurrentState on the FSM to update
       * its state.
       */
      function tick(fsm:IMachine):void;
      
      /**
       * Called when we transition out of this state.
       */
      function exit(fsm:IMachine):void;
   }
}