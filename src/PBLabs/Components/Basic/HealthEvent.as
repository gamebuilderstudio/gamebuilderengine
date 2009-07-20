package PBLabs.Components.Basic
{
	import flash.events.Event;
   import PBLabs.Engine.Entity.*;

   /**
    * Event fired by the HealthComponent on the entity when health changes.
    */
	public class HealthEvent extends Event
	{
      /**
       * Change in health.
       */
		public var Delta:Number;
      
      /**
       * Current health amount, after the delta. The health property on the 
       * component is not updated until after the event is processed.
       */
		public var Amount:Number;
      
      /**
       * Entity which caused this damage (or healing), if any.
       */
      public var OriginatingEntity:IEntity;
		
		public function HealthEvent(type:String, delta:Number, amount:Number, originator:IEntity, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			Delta = delta;
			Amount = amount;
         OriginatingEntity = originator;
			super(type, bubbles, cancelable);
		}
		
		public function IsDead():Boolean
		{
			return Amount == 0;
		}
	}
}