package com.pblabs.components.stateMachine
{
   import flash.events.Event;

    /**
     * Machine fires this event whenever it changes state.
     */
   public class TransitionEvent extends Event
   {
      public static const TRANSITION:String = "fsmStateTransition";
      
      public var oldState:IState;
      public var oldStateName:String;
      public var newState:IState;
      public var newStateName:String;
      
      public function TransitionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
      {
         super(type, bubbles, cancelable);
      }
      
   }
}