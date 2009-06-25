package PBLabs.Components.Basic
{
	import PBLabs.Engine.Entity.*;
	import PBLabs.Engine.Core.*;
   import PBLabs.Engine.Debug.*;
   import PBLabs.Engine.Math.*;
	import mx.controls.*;
   
	/**
	 * General purpose component for tracking health.
	 */
	public class HealthComponent extends EntityComponent
	{
		public var LastDamageTimeFade:Number = 200;
		public var MaxHealth:Number = 100;
		public var DestroyOnDeath:Boolean = true;
		public var DamageModifier:Array = new Array();
      public var DamageMagnitude:Number = 1.0;

		public static var DIED:String = "HealthDead";
		public static var RESURRECTED:String = "HealthResurrected";
		public static var DAMAGED:String = "HealthDamaged";
		public static var HEALED:String = "HealthHealed";
		
		protected override function _OnAdd():void
		{
			_Health = MaxHealth;
		}
		
		public function get TimeSinceLastDamage():Number
		{
			return ProcessManager.Instance.VirtualTime - _TimeOfLastDamage;
		}
		
		public function get LastDamageFade():Number
		{
			var f:Number = 1.0 - (TimeSinceLastDamage / LastDamageTimeFade);
			f *= DamageMagnitude;
			
			return Utility.Clamp(f);
		}
		
		public function get Health():Number
		{
			return _Health;
		}
		
		public function get AmountOfDamage():Number
		{
		   return MaxHealth - _Health;
		}
		
		public function set Health(v:Number):void
		{
			// Clamp the amount of damage.
			if(v < 0)
				v = 0;
			if(v > MaxHealth)
				v = MaxHealth;
			
			// Notify via a HealthEvent.
			var he:HealthEvent;
			
			if(v < _Health)
			{
				he = new HealthEvent(DAMAGED, v - _Health, v);
				Owner.EventDispatcher.dispatchEvent(he);
			}

			if(_Health > 0 && v == 0)
			{
				he = new HealthEvent(DIED, v - _Health, v);
				Owner.EventDispatcher.dispatchEvent(he);
			}
			
			if(_Health == 0 && v > 0)
			{
				he = new HealthEvent(RESURRECTED, v - _Health, v);
				Owner.EventDispatcher.dispatchEvent(he);
			}
			
			if(_Health > 0 && v > _Health)
			{
				he = new HealthEvent(HEALED, v - _Health, v);
				if(Owner && Owner.EventDispatcher)
					Owner.EventDispatcher.dispatchEvent(he);
			}

			// Set
         //Logger.Print(this, "Health becomes " + _Health);
			_Health = v;

			// Handle destruction...
			if(DestroyOnDeath && _Health <= 0)
			{
				// Kill the owning container if requested.
				Owner.Destroy();
			}
		}
		
		public function Damage(amount:Number, damageType:String = null):void
		{
		   // Allow modification of damage based on type.
		   if(damageType && DamageModifier.hasOwnProperty(damageType))
		   {
		      //Logger.Print(this, "Damage modified by entry for type '" + damageType + "' factor of " + DamageModifier[damageType]);
		      amount *= DamageModifier[damageType];
		   }
			
         // For the flash magnitude, average in preceding fade. 
         DamageMagnitude = Math.min(1.0 , (amount / _Health) * 4);
			_TimeOfLastDamage = ProcessManager.Instance.VirtualTime;

			// Apply the damage.
         Health -= amount;
		}
		
		public function get IsDead():Boolean
		{
			return _Health<=0;
		}

      private var _Health:Number = 100;
      private var _TimeOfLastDamage:Number = 0;

	}
}
