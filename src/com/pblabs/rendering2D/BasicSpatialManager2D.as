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
	import com.pblabs.engine.core.ObjectTypeManager;
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
       public function BasicSpatialManager2D()
       {
          //make sure our boxVsBox function works. this should be moved to an external unit test.
          boxVsBoxTest();
       }
       
      /**
       * @inheritDoc
       */
      public function addSpatialObject(object:ISpatialObject2D):void
      {
         _objectList.push(object);
      }
      
      /**
       * @inheritDoc
       */
      public function removeSpatialObject(object:ISpatialObject2D):void
      {
         var index:int = _objectList.indexOf(object);
         if (index == -1)
         {
            Logger.printWarning(this, "removeSpatialObject", "The object was not found in this spatial manager.");
            return;
         }
         
         _objectList.splice(index, 1);
      }
      
      private function boxVsBox(box1:Rectangle, box2:Rectangle):Boolean
      {
         return box1.intersects(box2);
      }
      
      /**
      * Tests the local boxVsBox function. This called when this class is 
      * instantiated to verify the function works as expected. It should be
      * moved to an external unit test.
      */
      private function boxVsBoxTest():void
      {
          //tall and skinny vs. short and fat. queue comedy.
          var box1:Rectangle = new Rectangle(0, 45, 100, 10);
          var box2:Rectangle = new Rectangle(45, 0, 10, 100);
          
          if (!boxVsBox(box1, box2) || !boxVsBox(box2, box1))
            throw Error("tall skinny box 1 vs. short fat box 2 failure");

          //fully overlapping
          box1 = new Rectangle(0, 0, 100, 100);
          box2 = new Rectangle(0, 0, 100, 100);

          if (!boxVsBox(box1, box2) || !boxVsBox(box2, box1))
            throw new Error("box 1 overlaps box 2 failure");

          //containing each other
          box1 = new Rectangle(0, 0, 100, 100);
          box2 = new Rectangle(45, 45, 10, 10);

          if (!boxVsBox(box1, box2) || !boxVsBox(box2, box1))
            throw new Error("box 1 fully contains box 2 failure");
            
          //topLeft
          box2 = new Rectangle(45, 45, 100, 100);
          
          if (!boxVsBox(box1, box2) || !boxVsBox(box2, box1))
            throw new Error("box 1 contains box 2 topLeft failure");
          
          //topRight
          box2 = new Rectangle(-45, 45, 100, 100);
          
          if (!boxVsBox(box1, box2) || !boxVsBox(box2, box1))
            throw new Error("box 1 contains box 2 topRight failure");
          
          //bottomLeft
          box2 = new Rectangle(45, -45, 100, 100);
          
          if (!boxVsBox(box1, box2) || !boxVsBox(box2, box1))
            throw new Error("box 1 contains box 2 bottomLeft failure");
          
          //bottomRight
          box2 = new Rectangle(-45, -45, 100, 100);
          
          if (!boxVsBox(box1, box2) || !boxVsBox(box2, box1))
            throw new Error("box 1 contains box 2 bottomRight failure");
            
          //negative test
          box1 = new Rectangle(0, 0, 100, 100);
          box2 = new Rectangle(-101, -101, 100, 100);

          if (boxVsBox(box1, box2) || boxVsBox(box2, box1))
            throw new Error("negative test failure");
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
            if (!ObjectTypeManager.instance.doTypesOverlap(object.objectMask, mask))
               continue;
            
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
            if (!ObjectTypeManager.instance.doTypesOverlap(object.objectMask, mask))
               continue;
            
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
      public function objectsUnderPoint(point:Point, mask:ObjectType, results:Array, scene:IDrawManager2D):Boolean
      {
         var tmpResults:Array = new Array();
         
         // First use the normal spatial query...
         if(!queryCircle(point, 64, mask, tmpResults))
            return false;
         
         // Ok, now pass control to the objects and see what they think.
         var hitAny:Boolean = false;
         for each(var tmp:ISpatialObject2D in tmpResults)
         {
            if(!tmp.pointOccupied(point, scene))
               continue;
            
            results.push(tmp);
            hitAny = true;
         }
         
         // Sort the results.
         if(scene)
            scene.sortSpatials(results);
         
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
         var boundingRect:Rectangle = new Rectangle(start.x, start.y, end.x - start.x, end.y - start.y);
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