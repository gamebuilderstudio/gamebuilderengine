package PBLabs.Components.StateMachine
{
   import PBLabs.Engine.Entity.IEntity;

   /**
   * State which destroys its owning container when it is entered.
   */
   public class DeathState extends BasicState
   {
      override public function Enter(fsm:IMachine):void
      {
         // Kill ourselves!
         var entity:IEntity = fsm.PropertyBag as IEntity;
         if(!entity)
            throw new Error("Cannot call Destroy on a non-entity!");
         entity.Destroy();
      }
      
   }
}