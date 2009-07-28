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
      public var stateMachine:IMachine;
      
      override protected function onAdd():void
      {
         super.onAdd();
         
         if(stateMachine)
            stateMachine.propertyBag = owner;
      }
      
      override protected function onRemove():void
      {
         super.onRemove();
         
         if(stateMachine)
            stateMachine.propertyBag = null;
      }
      
      override public function onTick(tickRate:Number) : void
      {
         if(stateMachine)
            stateMachine.tick();
      }
   }
}