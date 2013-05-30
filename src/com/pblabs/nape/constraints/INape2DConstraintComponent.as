package com.pblabs.nape.constraints
{
	import com.pblabs.engine.entity.IEntityComponent;
	import com.pblabs.nape.INape2DSpatialComponent;
	import com.pblabs.physics.IPhysics2DConstraint;
	
	import nape.constraint.Constraint;
	
	public interface INape2DConstraintComponent extends IPhysics2DConstraint, IEntityComponent
	{
		/**
		 * The 1st physics spatial used in the constraint setup 
		 */
		function get spatial1():INape2DSpatialComponent;
		function set spatial1(value:INape2DSpatialComponent):void;
		
		/**
		 * The 2nd physics spatial used in the constraint setup 
		 */
		function get spatial2():INape2DSpatialComponent;
		function set spatial2(value:INape2DSpatialComponent):void;
		
		function get constraint():Constraint		
	}
}