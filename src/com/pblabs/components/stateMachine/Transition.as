package com.pblabs.components.stateMachine
{
   /**
    * Basic, always-on transition.
    */
   public class Transition implements ITransition
   {
      private var _TargetState:String;
      
      public function Transition(targetState:String = null)
      {
         targetState = targetState;
      }
      
      public function evaluate(fsm:IMachine):Boolean
      {
         return true;
      }
      
      public function getTargetState():String
      {
         return _TargetState;
      }
      
      public function set targetState(value:String):void
      {
         _TargetState = value;
      }
   }
}