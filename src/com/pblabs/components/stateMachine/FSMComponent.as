package com.pblabs.components.stateMachine
{
   import flash.events.EventDispatcher;
   import com.pblabs.engine.entity.*;
   import com.pblabs.engine.components.*;

    /**
    * Component that wraps a state machine and updates it based on game ticks.
    */
   public class FSMComponent extends TickedComponent
   {
      public var StateMachine:Machine;
      
      protected override function onAdd():void
      {
         super.onAdd();
         
         if(StateMachine)
            StateMachine.propertyBag = owner;
      }
      
      protected override function onRemove():void
      {
         super.onRemove();
         
         if(StateMachine)
            StateMachine.propertyBag = null;
      }
      
      public override function onTick(tickRate:Number) : void
      {
         if(StateMachine)
            StateMachine.tick();
      }
   }
}