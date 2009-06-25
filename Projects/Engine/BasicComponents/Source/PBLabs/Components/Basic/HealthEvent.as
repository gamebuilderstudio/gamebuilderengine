package PBLabs.Components.Basic
{
	import flash.events.Event;

   /**
    * Event fired by the HealthComponent on the entity when health changes.
    */
	public class HealthEvent extends Event
	{
		public var Delta:Number;
		public var Amount:Number;
		
		public function HealthEvent(type:String, delta:Number, amount:Number, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			Delta = delta;
			Amount = amount;
			super(type, bubbles, cancelable);
		}
		
		public function IsDead():Boolean
		{
			return Amount == 0;
		}
	}
}