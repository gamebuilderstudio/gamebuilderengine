package com.pblabs.components.stateMachine
{
   /**
    * Basic, always-on transition.
    */
   public class Transition implements ITransition
   {
      private var _targetState:String;
      
      public function Transition(targetState:String = null)
      {
         _targetState = targetState;
      }
      
      public function evaluate(fsm:IMachine):Boolean
      {
         return true;
      }
      
      public function getTargetState():String
      {
         return _targetState;
      }
      
      public function set targetState(value:String):void
      {
         _targetState = value;
      }
   }
}