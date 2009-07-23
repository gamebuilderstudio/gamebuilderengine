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
      public var DamageMagnitude:Number = 1.0;

		public static var DIED:String = "HealthDead";
		public static var RESURRECTED:String = "HealthResurrected";
		public static var DAMAGED:String = "HealthDamaged";
		public static var HEALED:String = "HealthHealed";
		
		protected override function _OnAdd():void
		{
			_Health = MaxHealth;
         _TimeOfLastDamage = -1000;
		}
		
      /**
       * Time in milliseconds since the last damage this unit received.
       */
		public function get TimeSinceLastDamage():Number
		{
			return ProcessManager.Instance.VirtualTime - _TimeOfLastDamage;
		}
		
      /**
       * A value which fades from 1 to 0 as time passes since the last damage.
       */
		public function get LastDamageFade():Number
		{
			var f:Number = 1.0 - (TimeSinceLastDamage / LastDamageTimeFade);
			f *= DamageMagnitude;
			
			return Utility.Clamp(f);
		}
		
      /**
       * How far are we from being fully healthy?
       */
		public function get AmountOfDamage():Number
		{
		   return MaxHealth - _Health;
		}

		public function get Health():Number
		{
			return _Health;
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
				he = new HealthEvent(DAMAGED, v - _Health, v, _LastDamageOriginator);
				Owner.EventDispatcher.dispatchEvent(he);
			}

			if(_Health > 0 && v == 0)
			{
				he = new HealthEvent(DIED, v - _Health, v, _LastDamageOriginator);
				Owner.EventDispatcher.dispatchEvent(he);
			}
			
			if(_Health == 0 && v > 0)
			{
				he = new HealthEvent(RESURRECTED, v - _Health, v, _LastDamageOriginator);
				Owner.EventDispatcher.dispatchEvent(he);
			}
			
			if(_Health > 0 && v > _Health)
			{
				he = new HealthEvent(HEALED, v - _Health, v, _LastDamageOriginator);
				if(Owner && Owner.EventDispatcher)
					Owner.EventDispatcher.dispatchEvent(he);
			}

			// Set new health value.
         //Logger.Print(this, "Health becomes " + _Health);
			_Health = v;

			// Handle destruction...
			if(DestroyOnDeath && _Health <= 0)
			{
				// Kill the owning container if requested.
				Owner.Destroy();
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
		public function Damage(amount:Number, damageType:String = null, originator:IEntity = null):void
		{
         _LastDamageOriginator = originator;
         
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
         
         // If you wanted to do clever things with the last guy to hurt you,
         // you might want to keep this value set. But since it can have GC
         // implications and also lead to stale data we clear it.
         _LastDamageOriginator = null;
		}
		
		public function get IsDead():Boolean
		{
			return _Health <= 0;
		}

      private var _Health:Number = 100;
      private var _TimeOfLastDamage:Number = 0;
      private var _LastDamageOriginator:IEntity = null;

	}
}
