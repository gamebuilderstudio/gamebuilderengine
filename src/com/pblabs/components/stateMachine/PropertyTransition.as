package com.pblabs.components.stateMachine
{
   import com.pblabs.engine.entity.*;
   
   /**
    * Check that a component container property evaluates to some value before 
    * changing state. Expects a Machine FSM.
    */
   public class PropertyTransition extends Transition
   {
      public var Property:PropertyReference;
      public var Value:String;
      
      public override function evaluate(fsm:IMachine):Boolean
      {
         if(!fsm.propertyBag)
            return false;
         
         return fsm.propertyBag.getProperty(Property).toString() == Value;
      }
   }
}