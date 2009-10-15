package com.pblabs.rendering2D
{
    import com.pblabs.rendering2D.ui.IUITarget;
    import com.pblabs.engine.core.ObjectType;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
	public interface IScene2D
	{
        function get layerCount():int;
        function getLayer(index:int, allocateIfAbsent:Boolean = false):DisplayObjectSceneLayer;
        
        function get sceneView():IUITarget;
        function set sceneView(value:IUITarget):void;
        
        function add(dor:DisplayObjectRenderer):void
        function remove(dor:DisplayObjectRenderer):void;

        /**
         * Some scenes cache the view; calling this lets them know that they
         * need to redraw a region of the scene. Specified in scene coordinates.
         * @param dirtyRect Region to redraw, in scene space.
         */
        function invalidateRectangle(dirtyRect:Rectangle):void;
        
        function invalidate(dirtyRenderer:DisplayObjectRenderer):void;
        
        function getRenderersUnderPoint(screenPosition:Point, mask:ObjectType=null):Array;

        function setWorldCenter(position:Point):void;
        function screenPan(deltaX:int, deltaY:int):void;

        function get rotation():Number;
        function set rotation(value:Number):void;
        
        function get position():Point;
        function set position(value:Point) : void;
        
        function get zoom():Number;
        function set zoom(value:Number):void;

        /**
         * The region of the scene we are currently viewing.
         */
        function get sceneViewBounds():Rectangle;
        
        function transformWorldToScene(inPos:Point):Point;
        function transformSceneToWorld(inPos:Point):Point;

        function transformSceneToScreen(inPos:Point):Point;
        function transformScreenToScene(inPos:Point):Point;
        
        function transformWorldToScreen(inPos:Point):Point;
        function transformScreenToWorld(inPos:Point):Point;
        
        function sortSpatials(array:Array):void;
	}
}