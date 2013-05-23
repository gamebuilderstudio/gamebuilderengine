package com.pblabs.physics
{
	import com.pblabs.rendering2D.ISpatialManager2D;

	public interface IPhysics2DConstraint
	{
		/**
		 * The spatial manager this object belongs to.
		 */
		function get spatialManager():IPhysics2DManager;
		function set spatialManager(value:IPhysics2DManager):void;
	}
}