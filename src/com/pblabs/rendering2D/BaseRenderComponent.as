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
   import com.pblabs.engine.entity.*;
   
   import flash.geom.Point;

   /**
    * Base implementation for a 2d renderable component. This contains some
    * convenient helper logic in order to simplify implementing your own renderable
    * component.
    */
   [EditorData(ignore="true")]
   public class BaseRenderComponent extends EntityComponent implements IDrawable2D
   {
      /**
       * A reference for the position property on the owner entity. This should be a
       * point.
       */
      [TypeHint(type="flash.geom.Point")]
      public var PositionReference:PropertyReference;
      
      /**
       * A reference for the rotation property on the owner entity. This should be a
       * Number.
       */
      [TypeHint(type="Number")]
      public var RotationReference:PropertyReference;
      
      /**
       * A reference for the size property on the owner entity. This should be a
       * point.
       */
      [TypeHint(type="flash.geom.Point")]
      public var SizeReference:PropertyReference;
      
      /**
       * An offset to apply to the position retrieved from the PositionReference.
       */
      public var PositionOffset:Point = new Point(0, 0);
      
      /**
       * @inheritDoc
       */
      [EditorData(ignore="true")]
      public function get RenderSortKey():int
      {
         return _RenderSortKey;
      }
      
      /**
       * @inheritDoc
       */
      public function set RenderSortKey(value:int):void
      {
         _RenderSortKey = value;
      }
      
      [EditorData(ignore="true")]
      public function get RenderCacheKey():int
      {
         return _RenderCacheKey;
      }
      
      public function set RenderCacheKey(v:int):void
      {
         _RenderCacheKey = v;
      }

      public function InvalidateRenderCache():void
      {
         _RenderCacheKey = RenderCacheKeyManager.Token++;
      }

      /**
       * @inheritDoc
       */
      public function get LayerIndex():int
      {
         return _LayerIndex;
      }
      
      /**
       * @inheritDoc
       */
      public function set LayerIndex(value:int):void
      {
         _LayerIndex = value;
      }
      
      /**
       * @inheritDoc
       */
      public function get RenderPosition():Point
      {
         var position:Point = Owner.GetProperty(PositionReference);
         
         if (!position)
            return new Point(0, 0);
         
         return position.add(PositionOffset);
      }
      
      public function get RenderScale():Point
      {
         var scale:Point = Owner.GetProperty(SizeReference);
         
         if(!scale)
            return new Point(1,1);
         
         return scale;
      }
      
      /**
       * @inheritDoc
       */
      public function OnDraw(manager:IDrawManager2D):void
      {
         throw new Error("Derived classes must implement this method!");
      }
      
      private var _LayerIndex:int, _RenderSortKey:int, _RenderCacheKey:int;
   }
}