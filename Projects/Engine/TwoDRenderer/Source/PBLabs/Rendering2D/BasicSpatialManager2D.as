/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Rendering2D
{
   import PBLabs.Engine.Entity.*;
   import PBLabs.Engine.Core.*;
   import flash.geom.*;
 
   /**
    * Basic 2d spatial manager that stores everything in a list. There are many
    * smarter implementations, but this one is simple and reliable.
    */ 
   public class BasicSpatialManager2D extends EntityComponent implements ISpatialManager2D
   {
      public function AddSpatialObject(object:ISpatialObject2D):void
      {
         _ObjectList.push(object);
      }
      
      public function RemoveSpatialObject(object:ISpatialObject2D):void
      {
         var idx:int = _ObjectList.indexOf(object);
         if(idx == -1)
            throw new Error("Object not found.");
         _ObjectList.splice(idx, 1);
      }
      
      public function QueryRectangle(box:Rectangle, mask:ObjectType, results:Array):Boolean
      {
         var foundAny:Boolean = false;
         for each(var obj:ISpatialObject2D in _ObjectList)
         {
            if(ObjectTypeManager.Instance.DoTypesOverlap(obj.QueryMask, mask) == false)
               continue;
            
            if(obj.WorldExtents.intersects(box) == false)
               continue;
            
            results.push(obj);
            foundAny = true;
         }

         return foundAny;
      }
      
      public function QueryCircle(center:Point, radius:Number, mask:ObjectType, results:Array):Boolean
      {
         var foundAny:Boolean = false;
         for each(var obj:ISpatialObject2D in _ObjectList)
         {
            if(ObjectTypeManager.Instance.DoTypesOverlap(obj.QueryMask, mask) == false)
               continue;
            
            var scratchRect:Rectangle = obj.WorldExtents.clone();
            scratchRect.inflate(radius, radius);
            if(scratchRect.containsPoint(center) == false)
               continue;
            
            results.push(obj);
            foundAny = true;
         }

         return foundAny;
      }
      
      public function CastRay(start:Point, end:Point, mask:ObjectType, result:RayHitInfo):Boolean
      {
         // We want to return the first hit among all our items. We'll be very lazy,
         // and simply check against every potential match, taking the closest hit.
         // This will suck for long raycasts, but most of them are quite short.
         var results:Array = new Array();
         var boundingRect:Rectangle = new Rectangle(start.x, start.y, end.x - start.x, end.y - start.y);
         if(!QueryRectangle(boundingRect, mask, results))
            return false;
         
         var bestInfo:RayHitInfo = null;
         var tmpInfo:RayHitInfo = new RayHitInfo();

         for each(var obj:ISpatialObject2D in results)
         {
            
            if(obj.CastRay(start, end, tmpInfo))
            {
               if(bestInfo == null)
               {
                  bestInfo = new RayHitInfo();
                  bestInfo.CopyFrom(tmpInfo);
               }
               else if(tmpInfo.Time < bestInfo.Time)
               {
                  bestInfo.CopyFrom(tmpInfo);
               }
            }
         }
         
         if(bestInfo)
         {
            if(result)
               result.CopyFrom(bestInfo);
            return true;
         }
         
         return false;
      }
      
      private var _ObjectList:Array = new Array();
   }
}