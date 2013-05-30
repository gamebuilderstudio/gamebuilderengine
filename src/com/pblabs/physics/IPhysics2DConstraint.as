package com.pblabs.physics
{
	import flash.geom.Point;

	public interface IPhysics2DConstraint
	{
		/**
		 * The physics spatial manager used to simulate the constraint this object belongs to.
		 */
		function get spatialManager():IPhysics2DManager;
		function set spatialManager(value:IPhysics2DManager):void;
		
		/**
		 * Used to manually rebuild constraint
		 **/
		function resetConstraint():void;
		/**
		 * The 1st anchor point on the 1st spatial physics body used as the pivot or center point of the constraint
		 */
		function get anchor1():Point;
		function set anchor1(value:Point):void;
		/**
		 * The 1st anchor point on the 1st spatial physics body used as the pivot or center point of the constraint
		 */
		function get anchor2():Point;
		function set anchor2(value:Point):void;

		/**
		 * The active flag to enable this contraint
		 */
		function get active():Boolean;
		function set active(value:Boolean):void;
		/**
		 * Whether interactions between related Bodys will be ignored.
		 */
		function get ignore():Boolean;
		function set ignore(value:Boolean):void;

		/**
		 * Set if the constraint should be Stiff in its simulation
		 */
		function get stiff():Boolean;
		function set stiff(value:Boolean):void;

		/**
		 * Whether constraint will break once maxError is reached.
		 */
		function get breakUnderError():Boolean;
		function set breakUnderError(value:Boolean):void;

		/**
		 * Whether constraint will break once maxForce is reached.
		 */
		function get breakUnderMaxForce():Boolean;
		function set breakUnderMaxForce(value:Boolean):void;

		/**
		 * The maximum amount of force this constraint is allowed to withstand.
		 */
		function get maxForce():Number;
		function set maxForce(value:Number):void;

		/**
		 * The maximum amount of error this constraint is allowed to use.
		 */
		function get maxError():Number;
		function set maxError(value:Number):void;

		/**
		 * Frequency of elastic properties of constraint.
		 */
		function get frequency():Number;
		function set frequency(value:Number):void;
		
		/**
		 * The Damping ratio of elastic properties of constraint.
		 */
		function get damping():Number;
		function set damping(value:Number):void;
	}
}