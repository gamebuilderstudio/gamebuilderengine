package com.pblabs.components.basic
{
	import flash.events.Event;
   import com.pblabs.engine.entity.*;

   /**
    * Event fired by the HealthComponent on the entity when health changes.
    */
	public class HealthEvent extends Event
	{
      /**
       * Change in health.
       */
		public var delta:Number;
      
      /**
       * Current health amount, after the delta. The health property on the 
       * component is not updated until after the event is processed.
       */
		public var amount:Number;
      
      /**
       * Entity which caused this damage (or healing), if any.
       */
      public var originatingEntity:IEntity;
		
		public function HealthEvent(type:String, delta:Number, amount:Number, originator:IEntity, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			delta = delta;
			amount = amount;
         originatingEntity = originator;
			super(type, bubbles, cancelable);
		}
		
		public function isDead():Boolean
		{
			return amount == 0;
		}
	}
}