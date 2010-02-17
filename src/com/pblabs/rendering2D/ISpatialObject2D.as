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
    
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    /**
     * Object with extents and ability to be ray-casted.
     * 
     * This is the basic interface for objects that support 2D spatial queries.
     * It is enough to do broad phase collision checks and ray casts.
     */ 
    public interface ISpatialObject2D
    {
        /**
         * Axis aligned object bounds in world space.
         */ 
        function get worldExtents():Rectangle;
        
        /**
         * This object's collision flags.
         */ 
        function get objectMask():ObjectType;
        
        /**
         * Perform a ray cast against this object.
         */ 
        function castRay(start:Point, end:Point, flags:ObjectType, result:RayHitInfo):Boolean;
        
        /**
         * Return true if the specified point is occupied by this object, used for
         * ObjectsUnderPoint.
         *
         * @param pos Location in worldspace to check.
         * @param scene If we want to have the results line up with the view, we
         *              need access to the scene we're doing the check from.
         */
        function pointOccupied(pos:Point, mask:ObjectType, scene:IScene2D):Boolean;
    }
}