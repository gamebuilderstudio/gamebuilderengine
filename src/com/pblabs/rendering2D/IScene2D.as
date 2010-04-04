/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.rendering2D
{
    import com.pblabs.engine.core.ObjectType;
    import com.pblabs.rendering2D.ui.IUITarget;
    
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    /**
     * Base interface for a 2d scene. A scene contains multiple layers, and has
     * a camera transform which is applied to pan/rotate/zoom the view. The scene
     * is responsible for tracking and rendering all the drawable objects in the
     * world.
     * 
     * @see DisplayObjectRenderer
     * @see DisplayObjectScene
     */
    public interface IScene2D
    {
        /**
         * How the scene is aligned relative to its position property.
         * 
         * @see SceneAlignment
         * @see position 
         */
        function set sceneAlignment(value:SceneAlignment):void;
        
        /**
         * @private
         */ 
        function get sceneAlignment():SceneAlignment;
        
        /**
         * Layers are assigned positive integers between 0 and N. This tells 
         * you what N is. This can be the same as how many layers there are,
         * but you might only be using layers 2,3, and 7, in which case
         * layerCount will be 8, but there will only be three layers. 
         * 
         * <p>layerCount is mostly useful in order to iterate over all the
         * layers by calling getLayer.</p>
         * 
         * @see getLayer
         */
        function get layerCount():int;

        /**
         * Get the layer at specified index. 
         * @param index Index of layer to return.
         * @param allocateIfAbsent False by default. If true, will allocate a 
         *                         new layer if none is present.
         * @return The requested layer.
         */
        function getLayer(index:int, allocateIfAbsent:Boolean = false):DisplayObjectSceneLayer;
                
        /**
         * The SceneView where the contents of this scene will be displayed. 
         */
        function set sceneView(value:IUITarget):void;

        /**
         * @private 
         */
        function get sceneView():IUITarget;
        
        /**
         * Add a DisplayObjectRenderer to the scene; all you normally have to
         * do is set scene on DisplayObjectRenderer, not call this directly.
         */
        function add(dor:DisplayObjectRenderer):void

        /**
         * Remove a DisplayObjectRenderer from the scene; all you normally have
         * to do is clear scene on DisplayObjectRenderer, or destroy its owning
         * entity, not call this directly.
         */
        function remove(dor:DisplayObjectRenderer):void;

        /**
         * Indicates that a renderer has changed, and must be redrawn. Only 
         * necessary if you are using layers that implement ICachingLayer
         * (you don't by default).
         * 
         * @param dirtyRenderer The renderer that has changed.
         */
        function invalidate(dirtyRenderer:DisplayObjectRenderer):void;
        
        /**
         * Just like invalidate, but indicates a specific region in scene 
         * coordinates. All layers will have that region redrawn.
         * @param dirty The region to redraw.
         */
        function invalidateRectangle(dirty:Rectangle):void;
        
        /**
         * Return a sorted list of the DisplayObjectRenderers under a given 
         * screen position.
         *  
         * @param screenPosition Location on screen we are curious about.
		 * @param results An array into which DisplayObjectRenderers are added based on what is under point.  
         * @param mask Only renderers with one or more of these bits set on their objectMask will be returned. Null uses all types.
		 * @return Found something under point or not.
         */
		function getRenderersUnderPoint(screenPosition:Point, results:Array, mask:ObjectType = null):Boolean;

        /**
         * Center the view on a position in world space.
         */
        function setWorldCenter(position:Point):void;
        
        /**
         * Pan-the view by (deltaX, deltaY) screen pixels. This takes into account zoom.
         */
        function screenPan(deltaX:int, deltaY:int):void;

        /**
         * Rotation in degrees about the center point of the scene.
         */
        function set rotation(value:Number):void;

        /**
         * @private
         */
        function get rotation():Number;
        
        /**
         * The location of the view onto the scene. This is affected by sceneAlignment.  
         */
        function set position(value:Point) : void;

        /**
         * @private
         */
        function get position():Point;
        
        /**
         * Zoom/scale factor; 1 = no zoom, less than 1 = zoom out, greater than 1 = zoom in. 
         */
        function set zoom(value:Number):void;

        /**
         * @private
         */
        function get zoom():Number;
        
        /**
         * The region of the scene we are currently viewing.
         */
        function get sceneViewBounds():Rectangle;

        /**
         * If set, this clamps the camera to scroll no further than its boundaries
         */
        function set trackLimitRectangle(value:Rectangle):void;
        
        /**
         * @private
         */
        function get trackLimitRectangle():Rectangle;
        
        function transformWorldToScene(inPos:Point):Point;
        function transformSceneToWorld(inPos:Point):Point;

        function transformSceneToScreen(inPos:Point):Point;
        function transformScreenToScene(inPos:Point):Point;
        
        function transformWorldToScreen(inPos:Point):Point;
        function transformScreenToWorld(inPos:Point):Point;
        
        function sortSpatials(array:Array):void;
    }
}