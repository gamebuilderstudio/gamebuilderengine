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
    * Basic interface for 2D spatial database.
    * 
    * This provides enough capabilities to do visibility culling, limited picking,
    * and ray casts.
    * 
    * Most implementations (like ones using a physics library) will expose a
    * lot more functionality, but this is enough to do rendering and UI tasks.
    */ 
   public interface ISpatialManager2D
   {
      /**
       * Add a generic spatial object to this manager. A manager with advanced
       * functionality will support both general ISpatialObject2D implementations
       * as well as enabling special functionality for its peered classes.
       */ 
      function addSpatialObject(object:ISpatialObject2D):void;

      /**
       * Remove a previously registered object from this manager.
       * 
       * @see AddSpatialObject
       */ 
      function removeSpatialObject(object:ISpatialObject2D):void;
      
      /**
       * Return all the spatial objects that overlap with the specified box and match
       * one or more of the types in the mask.
       * 
       * <p>Note that if you pass in a populated array, this method appends to it.
       * This can be useful if you want to combine the results of several
       * queries. If you just want the results from one query, make sure to
       * set results.length=0; before you pass it to queryRectangle.</p>
       * 
       * @return True if one or more objects were found and push()'ed to results.
       */ 
      function queryRectangle(box:Rectangle, mask:ObjectType, results:Array):Boolean;
      
      /**
       * Return all the spatial objects that overlap the specified circle.
       * 
       * @see QueryRectangle
       */ 
      function queryCircle(center:Point, radius:Number, mask:ObjectType, results:Array):Boolean;
      
      /**
       * Cast a ray and (optionally) return information about what it hits in result.
       */
      function castRay(start:Point, end:Point, flags:ObjectType, result:RayHitInfo):Boolean;

      /**
       * Return all the spatial objects under a given point. Objects can optionally implement
       * pixel-level collision checking.
       *
       * @param worldPosition Point in worldspace to check.
       * @param results An array into which ISpatialObject2Ds are added based on what is under point.
       * @param mask Only consider objects that match this ObjectType. Null uses all types.
  	   * @return Found something under point or not.
       */
      function getObjectsUnderPoint(worldPosition:Point, results:Array, mask:ObjectType = null):Boolean;
   }
}