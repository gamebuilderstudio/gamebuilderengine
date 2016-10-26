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
	import com.pblabs.engine.PBUtil;
	import com.pblabs.engine.core.ObjectType;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.debug.Profiler;
	import com.pblabs.engine.entity.EntityComponent;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;

   /**
    * Basic 2d spatial manager that stores everything in a list. There are many
    * smarter implementations, but this one is simple and reliable.
    */ 
   public class BasicSpatialManager2D extends EntityComponent implements ISpatialManager2D
   {
      /**
       * @inheritDoc
       */
      public function addSpatialObject(object:ISpatialObject2D):void
      {
		  if(_spatialList.indexOf(object) == -1)
         	_spatialList.push(object);
      }
      
      /**
       * @inheritDoc
       */
      public function removeSpatialObject(object:ISpatialObject2D):void
      {
         var index:int = _spatialList.indexOf(object);
         if (index == -1)
         {
            Logger.warn(this, "removeSpatialObject", "The object was not found in this spatial manager.");
            return;
         }
         
		 PBUtil.splice(_spatialList, index, 1);
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
      public function queryRectangle(box:Rectangle, mask:ObjectType, results:Array, checkSpatialBounds : Boolean = false):Boolean
      {
         Profiler.enter("QueryRectangle");

         var foundAny:Boolean = false;
		 var len : int = _spatialList.length;
		 for(var i : int = 0; i < len; i++)
		 {
			 var object:ISpatialObject2D = _spatialList[i];
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
         
		 var len : int = _spatialList.length;
		 for(var i : int = 0; i < len; i++)
		 {
			var object:ISpatialObject2D = _spatialList[i];
			if (mask != null)
			{
				if (!PBE.objectTypeManager.doTypesOverlap(object.objectMask, mask))
					continue;
			}
            
            // Avoid allocations - so manually copy.
			_tmpRect = object.worldExtents;
            _scratchRect.x = _tmpRect.x;
			_scratchRect.y = _tmpRect.y;
			_scratchRect.width = _tmpRect.width;
			_scratchRect.height = _tmpRect.height;
            
			_scratchRect.inflate(radius, radius);
            
            if (!_scratchRect.containsPoint(center))
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
	  public function getObjectsUnderPoint(worldPosition:Point, results:Array, mask:ObjectType = null, convertFromStageCoordinates : Boolean = false, checkSpatialPixels : Boolean = true):Boolean
      {
         // Ok, now pass control to the objects and see what they think.
         var hitAny:Boolean = false;
		 for(var i : int = 0; i < _spatialList.length; i++)
		 {
			 var object:ISpatialObject2D = _spatialList[i];
			 if (mask != null)
			 {
				 if (!PBE.objectTypeManager.doTypesOverlap(object.objectMask, mask))
					 continue;
			 }
			 
            if (checkSpatialPixels && !object.pointOccupied(worldPosition, mask, null, convertFromStageCoordinates))
               continue;
			else if(!checkSpatialPixels && !object.worldExtents.containsPoint(worldPosition))
				continue;
				
            if(!results)
				results = [];
            results.push(object);
            hitAny = true;
         }
         
         // Sort the results.
         if(PBE.scene && results)
            PBE.scene.sortSpatials(results);
         
         return hitAny;
      }
      
	  /**
	   * @inheritDoc
	   */
	  public function getObjectsInRec(worldRec:Rectangle, results:Array, checkSpatialPixels : Boolean = false):Boolean
	  {
		  var tmpResults:Array = [];
		  
		  // First use the normal spatial query...
		  queryRectangle(worldRec, null, tmpResults, checkSpatialPixels)
		  
		  // Ok, now check the renderer on all spatials with one as a last resort to check their bounds.
		  var hitAny:Boolean = false;
		  var len : int = _spatialList.length;
		  for(var i : int = 0; i < len; i++)
		  {
			  var tmp:ISpatialObject2D =  _spatialList[i];
			  if(results.indexOf( tmp ) != -1)
				  continue;
			  var rendererRec : Rectangle = tmp.worldExtents;
			  if (rendererRec && !rendererRec.intersects( worldRec ))
				  continue;
			  results.push(tmp);
			  hitAny = true;
		  }
		  
		  return hitAny;
	  }

	  /**
       * @inheritDoc
       */
      public function castRay(start:Point, end:Point, mask:ObjectType, result:RayHitInfo):Boolean
      {
		  return false;
		  
         // We want to return the first hit among all our items. We'll be very lazy,
         // and simply check against every potential match, taking the closest hit.
         // This will suck for long raycasts, but most of them are quite short.
         var results:Array = [];
		 _scratchRect.setTo(
			 Math.min(start.x, end.x) - 0.5,
			 Math.min(start.y, end.y) - 0.5, 
			 Math.abs(end.x - start.x) + 1, 
			 Math.abs(end.y - start.y) + 1);
			 
         if (!queryRectangle(_scratchRect, mask, results))
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
	  
	  public function get spatialsList():Vector.<ISpatialObject2D>
	  {
		  return _spatialList.concat();
	  }
      
      protected var _spatialList:Vector.<ISpatialObject2D> = new Vector.<ISpatialObject2D>();
	  private var _scratchRect : Rectangle = new Rectangle();
	  private var _tmpRect : Rectangle;
   }
}