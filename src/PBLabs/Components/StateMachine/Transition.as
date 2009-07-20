package PBLabs.Components.StateMachine
{
   /**
    * Basic, always-on transition.
    */
   public class Transition implements ITransition
   {
      private var _TargetState:String;
      
      public function Transition(targetState:String = null)
      {
         TargetState = targetState;
      }
      
      public function Evaluate(fsm:IMachine):Boolean
      {
         return true;
      }
      
      public function GetTargetState():String
      {
         return _TargetState;
      }
      
      public function set TargetState(v:String):void
      {
         _TargetState = v;
      }
   }
}