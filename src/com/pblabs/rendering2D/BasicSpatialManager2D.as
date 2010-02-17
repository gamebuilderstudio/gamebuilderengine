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
	import com.pblabs.engine.PBE;
    import com.pblabs.engine.core.ObjectType;
    import com.pblabs.engine.core.ObjectTypeManager;
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.engine.debug.Profiler;
    import com.pblabs.engine.entity.EntityComponent;
    
    import flash.events.Event;
    import flash.geom.Point;
    import flash.geom.Rectangle;

   /**
    * Basic 2d spatial manager that stores everything in a list. There are many
    * smarter implementations, but this one is simple and reliable.
    */ 
   public class BasicSpatialManager2D extends EntityComponent implements ISpatialManager2D
   {
      /**
      * An event with this name is raised on the owner.eventDispatcher when 
      * the entity list changes via addSpatialObject or removeSpatialObject.
      */
      public static const EntitiesDirtyEvent:String = "BasicSpatialManager2D.EntitiesDirty";
        
      /**
       * @inheritDoc
       */
      public function addSpatialObject(object:ISpatialObject2D):void
      {
         _objectList.push(object);
         if (owner && owner.eventDispatcher)
            owner.eventDispatcher.dispatchEvent(new Event(EntitiesDirtyEvent));
      }
      
      /**
       * @inheritDoc
       */
      public function removeSpatialObject(object:ISpatialObject2D):void
      {
         var index:int = _objectList.indexOf(object);
         if (index == -1)
         {
            Logger.warn(this, "removeSpatialObject", "The object was not found in this spatial manager.");
            return;
         }
         
         _objectList.splice(index, 1);
         if (owner && owner.eventDispatcher)
            owner.eventDispatcher.dispatchEvent(new Event(EntitiesDirtyEvent));
      }

      /**
      * Determines if the two rectangles intersect.
      * This, along with the objectMask of the spatial component is used in queryRectangle 
      * to determine which spatial components are added to the results array.
      */  
      public function boxVsBox(box1:Rectangle, box2:Rectangle):Boolean
      {
         return box1.intersects(box2);
      }
      
      /**
       * @inheritDoc
       */
      public function queryRectangle(box:Rectangle, mask:ObjectType, results:Array):Boolean
      {
         Profiler.enter("QueryRectangle");

         var foundAny:Boolean = false;
         for each (var object:ISpatialObject2D in _objectList)
         {
			if (mask != null)
			{
				if (!PBE.objectTypeManager.doTypesOverlap(object.objectMask, mask))
					continue;
            }
			
            if(!boxVsBox(object.worldExtents, box))
               continue;
            
            results.push(object);
            foundAny = true;
         }
         
         Profiler.exit("QueryRectangle");
         return foundAny;
      }
      
      /**
       * @inheritDoc
       */
      public function queryCircle(center:Point, radius:Number, mask:ObjectType, results:Array):Boolean
      {
         Profiler.enter("QueryCircle");

         var foundAny:Boolean = false;
         
         var scratchRect:Rectangle = new Rectangle();
         var tmpRect:Rectangle = new Rectangle();
         
         for each (var object:ISpatialObject2D in _objectList)
         {
			if (mask != null)
			{
				if (!PBE.objectTypeManager.doTypesOverlap(object.objectMask, mask))
					continue;
			}
            
            // Avoid allocations - so manually copy.
            tmpRect = object.worldExtents;
            scratchRect.x = tmpRect.x;
            scratchRect.y = tmpRect.y;
            scratchRect.width = tmpRect.width;
            scratchRect.height = tmpRect.height;
            
            scratchRect.inflate(radius, radius);
            
            if (!scratchRect.containsPoint(center))
               continue;
            
            results.push(object);
            foundAny = true;
         }

         Profiler.exit("QueryCircle");

         return foundAny;
      }
      
      /**
       * @inheritDoc
       */
	  public function getObjectsUnderPoint(worldPosition:Point, results:Array, mask:ObjectType = null):Boolean
      {
         var tmpResults:Array = new Array();
         
         // First use the normal spatial query...
         if(!queryCircle(worldPosition, 64, mask, tmpResults))
            return false;
         
         // Ok, now pass control to the objects and see what they think.
         var hitAny:Boolean = false;
         for each(var tmp:ISpatialObject2D in tmpResults)
         {
            if (!tmp.pointOccupied(worldPosition, mask, PBE.scene))
               continue;
            
            results.push(tmp);
            hitAny = true;
         }
         
         // Sort the results.
         if(PBE.scene)
            PBE.scene.sortSpatials(results);
         
         return hitAny;
      }
      
      /**
       * @inheritDoc
       */
      public function castRay(start:Point, end:Point, mask:ObjectType, result:RayHitInfo):Boolean
      {
         // We want to return the first hit among all our items. We'll be very lazy,
         // and simply check against every potential match, taking the closest hit.
         // This will suck for long raycasts, but most of them are quite short.
         var results:Array = new Array();
         var boundingRect:Rectangle = new Rectangle(
                            Math.min(start.x, end.x) - 0.5, 
                            Math.min(start.y, end.y) - 0.5, 
                            Math.abs(end.x - start.x) + 1, 
                            Math.abs(end.y - start.y) + 1);
         if (!queryRectangle(boundingRect, mask, results))
            return false;
         
         var bestInfo:RayHitInfo = null;
         var tempInfo:RayHitInfo = new RayHitInfo();

         for each (var object:ISpatialObject2D in results)
         {
            
            if (object.castRay(start, end, mask, tempInfo))
            {
               if (!bestInfo)
               {
                  bestInfo = new RayHitInfo();
                  bestInfo.copyFrom(tempInfo);
               }
               else if (tempInfo.time < bestInfo.time)
               {
                  bestInfo.copyFrom(tempInfo);
               }
            }
         }
         
         if (bestInfo)
         {
            if (result)
               result.copyFrom(bestInfo);
            
            return true;
         }
         
         return false;
      }
      
      protected var _objectList:Array = new Array();
   }
}