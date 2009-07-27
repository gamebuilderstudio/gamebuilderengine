package com.pblabs.components.stateMachine
{
   /**
    * Transition interface used by BasicState. Transitions are processed to
    * determine what state to go to next, usually each time their owning state
    * is ticked.
    */
   public interface ITransition
   {
      /**
       * What state will we be transitioning to?
       */
      function getTargetState():String;
      
      /**
       * evaluate the conditions for this state; if true then we go to
       * this transition's target.
       */
      function evaluate(fsm:IMachine):Boolean;
   }
}