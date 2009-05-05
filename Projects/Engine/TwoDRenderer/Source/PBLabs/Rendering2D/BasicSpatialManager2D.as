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
   import flash.geom.*;
   
   import PBLabs.Engine.Debug.Logger;
   import PBLabs.Engine.Entity.*;
   import PBLabs.Engine.Core.*;
 
   /**
    * Basic 2d spatial manager that stores everything in a list. There are many
    * smarter implementations, but this one is simple and reliable.
    */ 
   public class BasicSpatialManager2D extends EntityComponent implements ISpatialManager2D
   {
      /**
       * @inheritDoc
       */
      public function AddSpatialObject(object:ISpatialObject2D):void
      {
         _objectList.push(object);
      }
      
      /**
       * @inheritDoc
       */
      public function RemoveSpatialObject(object:ISpatialObject2D):void
      {
         var index:int = _objectList.indexOf(object);
         if (index == -1)
         {
            Logger.PrintWarning(this, "RemoveSpatialObject", "The object was not found in this spatial manager.");
            return;
         }
         
         _objectList.splice(index, 1);
      }
      
      private function boxVsBox(box1:Rectangle, box2:Rectangle):Boolean
      {
         if(box1.containsPoint(box2.topLeft))
            return true;
         if(box1.containsPoint(box2.bottomRight))
            return true;
         if(box2.containsPoint(box1.topLeft))
            return true;
         if(box2.containsPoint(box1.bottomRight))
            return true;
         return false;
      }
      /**
       * @inheritDoc
       */
      public function QueryRectangle(box:Rectangle, mask:ObjectType, results:Array):Boolean
      {
         var foundAny:Boolean = false;
         for each (var object:ISpatialObject2D in _objectList)
         {
            if (!ObjectTypeManager.Instance.DoTypesOverlap(object.QueryMask, mask))
               continue;
            
            if(boxVsBox(object.WorldExtents, box) == false)
               continue;
            
            results.push(object);
            foundAny = true;
         }

         return foundAny;
      }
      
      /**
       * @inheritDoc
       */
      public function QueryCircle(center:Point, radius:Number, mask:ObjectType, results:Array):Boolean
      {
         var foundAny:Boolean = false;
         for each (var object:ISpatialObject2D in _objectList)
         {
            if (!ObjectTypeManager.Instance.DoTypesOverlap(object.QueryMask, mask))
               continue;
            
            var scratchRect:Rectangle = object.WorldExtents.clone();
            scratchRect.inflate(radius, radius);
            if (!scratchRect.containsPoint(center))
               continue;
            
            results.push(object);
            foundAny = true;
         }

         return foundAny;
      }
      
      /**
       * @inheritDoc
       */
      public function CastRay(start:Point, end:Point, mask:ObjectType, result:RayHitInfo):Boolean
      {
         // We want to return the first hit among all our items. We'll be very lazy,
         // and simply check against every potential match, taking the closest hit.
         // This will suck for long raycasts, but most of them are quite short.
         var results:Array = new Array();
         var boundingRect:Rectangle = new Rectangle(start.x, start.y, end.x - start.x, end.y - start.y);
         if (!QueryRectangle(boundingRect, mask, results))
            return false;
         
         var bestInfo:RayHitInfo = null;
         var tempInfo:RayHitInfo = new RayHitInfo();

         for each (var object:ISpatialObject2D in results)
         {
            
            if (object.CastRay(start, end, tempInfo))
            {
               if (bestInfo == null)
               {
                  bestInfo = new RayHitInfo();
                  bestInfo.CopyFrom(tempInfo);
               }
               else if (tempInfo.Time < bestInfo.Time)
               {
                  bestInfo.CopyFrom(tempInfo);
               }
            }
         }
         
         if (bestInfo)
         {
            if (result)
               result.CopyFrom(bestInfo);
            
            return true;
         }
         
         return false;
      }
      
      private var _objectList:Array = new Array();
   }
}