package com.pblabs.components.basic
{
	import com.pblabs.engine.entity.*;
	import com.pblabs.engine.core.*;
   import com.pblabs.engine.debug.*;
   import com.pblabs.engine.math.*;
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
      public var damageMagnitude:Number = 1.0;

		public static var DIED:String = "HealthDead";
		public static var RESURRECTED:String = "HealthResurrected";
		public static var DAMAGED:String = "HealthDamaged";
		public static var HEALED:String = "HealthHealed";
		
		protected override function onAdd():void
		{
			_Health = MaxHealth;
         _TimeOfLastDamage = -1000;
		}
		
      /**
       * Time in milliseconds since the last damage this unit received.
       */
		public function get timeSinceLastDamage():Number
		{
			return ProcessManager.instance.virtualTime - _TimeOfLastDamage;
		}
		
      /**
       * A value which fades from 1 to 0 as time passes since the last damage.
       */
		public function get lastDamageFade():Number
		{
			var f:Number = 1.0 - (timeSinceLastDamage / LastDamageTimeFade);
			f *= damageMagnitude;
			
			return Utility.clamp(f);
		}
		
      /**
       * How far are we from being fully healthy?
       */
		public function get amountOfDamage():Number
		{
		   return MaxHealth - _Health;
		}

		public function get health():Number
		{
			return _Health;
		}
		
		public function set health(value:Number):void
		{
			// Clamp the amount of damage.
			if(value < 0)
				value = 0;
			if(value > MaxHealth)
				value = MaxHealth;
			
			// Notify via a HealthEvent.
			var he:HealthEvent;
			
			if(value < _Health)
			{
				he = new HealthEvent(DAMAGED, value - _Health, value, _LastDamageOriginator);
				owner.eventDispatcher.dispatchEvent(he);
			}

			if(_Health > 0 && value == 0)
			{
				he = new HealthEvent(DIED, value - _Health, value, _LastDamageOriginator);
				owner.eventDispatcher.dispatchEvent(he);
			}
			
			if(_Health == 0 && value > 0)
			{
				he = new HealthEvent(RESURRECTED, value - _Health, value, _LastDamageOriginator);
				owner.eventDispatcher.dispatchEvent(he);
			}
			
			if(_Health > 0 && value > _Health)
			{
				he = new HealthEvent(HEALED, value - _Health, value, _LastDamageOriginator);
				if(owner && owner.eventDispatcher)
					owner.eventDispatcher.dispatchEvent(he);
			}

			// Set new health value.
         //Logger.print(this, "Health becomes " + _Health);
			_Health = value;

			// Handle destruction...
			if(DestroyOnDeath && _Health <= 0)
			{
				// Kill the owning container if requested.
				owner.destroy();
			}
		}
		
      /** 
       * Apply damage!
       *
       * @param amount Number of HP to debit (positive) or credit (negative).
       * @param damage damageType String identifier for the type of damage. Used
       *                          to lookup and apply a damage modifier from DamageModifier.
       * @param originator The entity causing the damage, if any.
       */
		public function damage(amount:Number, damageType:String = null, originator:IEntity = null):void
		{
         _LastDamageOriginator = originator;
         
		   // Allow modification of damage based on type.
		   if(damageType && DamageModifier.hasOwnProperty(damageType))
		   {
		      //Logger.print(this, "Damage modified by entry for type '" + damageType + "' factor of " + DamageModifier[damageType]);
		      amount *= DamageModifier[damageType];
		   }
			
         // For the flash magnitude, average in preceding fade. 
         damageMagnitude = Math.min(1.0 , (amount / _Health) * 4);
			_TimeOfLastDamage = ProcessManager.instance.virtualTime;

			// Apply the damage.
         health -= amount;
         
         // If you wanted to do clever things with the last guy to hurt you,
         // you might want to keep this value set. But since it can have GC
         // implications and also lead to stale data we clear it.
         _LastDamageOriginator = null;
		}
		
		public function get isDead():Boolean
		{
			return _Health <= 0;
		}

      private var _Health:Number = 100;
      private var _TimeOfLastDamage:Number = 0;
      private var _LastDamageOriginator:IEntity = null;

	}
}
