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
   import flash.geom.Point;
   
   /**
    * Information about the results of a ray cast. Used with 
    * ISpatialManager2D.CastRay().
    */ 
   public final class RayHitInfo
   {
      /**
       * Ranges from 0..1, 0 being at the start of the ray and 1 at the end.
       * Indicates location of contact along the ray.
       */ 
      public var Time:Number;
      
      /**
       * Position of the contact.
       */ 
      public var Position:Point;
      
      /**
       * Normal of the contact.
       */ 
      public var Normal:Point;
      
      /**
       * The specific object the ray struck.
       */ 
      public var HitObject:ISpatialObject2D;
      
      /**
       * Copy state from another RayHitInfo, overwriting the information in this
       * RayHitInfo.
       */
      public function copyFrom(other:RayHitInfo):void
      {
         Time = other.Time;
         
         if(other.Position)
            Position = other.Position.clone();
         else
            Position = null;
         
         if(other.Normal)
            Normal = other.Normal.clone();
         else
            Normal = null;
         HitObject = other.HitObject;
      }
   }
}