package com.pblabs.rendering2D
{
    import flash.geom.Point;
    import com.pblabs.engine.core.ObjectType;

    /**
     * Implemented by layers which do their own entities-under-point logic. 
     */
	public interface ILayerMouseHandler
	{
        function getRenderersUnderPoint(screenPosition:Point, mask:ObjectType, results:Array):void;
	}
}