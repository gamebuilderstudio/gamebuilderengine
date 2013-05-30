package com.pblabs.nape
{
	import com.pblabs.engine.entity.IEntityComponent;
	import com.pblabs.physics.IPhysics2DSpatial;
	
	import nape.phys.Body;
	
	public interface INape2DSpatialComponent extends IPhysics2DSpatial, IEntityComponent
	{
		function get body():Body
	}
}