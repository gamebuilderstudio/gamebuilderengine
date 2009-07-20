package PBLabs.Components.StateMachine
{
   import PBLabs.Engine.Entity.*;
   
   /**
    * Check that a component container property evaluates to some value before 
    * changing state. Expects a Machine FSM.
    */
   public class PropertyTransition extends Transition
   {
      public var Property:PropertyReference;
      public var Value:String;
      
      public override function Evaluate(fsm:IMachine):Boolean
      {
         if(fsm.PropertyBag == null)
            return false;
         
         return fsm.PropertyBag.GetProperty(Property).toString() == Value;
      }
   }
}