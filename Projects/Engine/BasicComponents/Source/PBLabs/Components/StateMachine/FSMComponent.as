package PBLabs.Components.StateMachine
{
   import flash.events.EventDispatcher;
   import PBLabs.Engine.Entity.*;
   import PBLabs.Engine.Components.*;

    /**
    * Component that wraps a state machine and updates it based on game ticks.
    */
   public class FSMComponent extends TickedComponent
   {
      public var StateMachine:Machine;
      
      protected override function _OnAdd():void
      {
         super._OnAdd();
         
         if(StateMachine)
            StateMachine.PropertyBag = Owner;
      }
      
      protected override function _OnRemove():void
      {
         super._OnRemove();
         
         if(StateMachine)
            StateMachine.PropertyBag = null;
      }
      
      public override function OnTick(tickRate:Number) : void
      {
         if(StateMachine)
            StateMachine.Tick();
      }
   }
}