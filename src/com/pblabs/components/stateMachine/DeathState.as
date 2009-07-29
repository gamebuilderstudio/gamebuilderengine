package com.pblabs.components.stateMachine
{
   import com.pblabs.engine.entity.IEntity;

   /**
   * State which destroys its owning container when it is entered.
   */
   public class DeathState extends BasicState
   {
      override public function enter(fsm:IMachine):void
      {
         // Kill ourselves!
         var entity:IEntity = fsm.propertyBag as IEntity;
         if(!entity)
            throw new Error("Cannot call Destroy on a non-entity!");
         entity.destroy();
      }
   }
}