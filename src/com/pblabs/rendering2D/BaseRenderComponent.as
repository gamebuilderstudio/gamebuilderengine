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
      public function get renderSortKey():int
      {
         return _RenderSortKey;
      }
      
      /**
       * @inheritDoc
       */
      public function set renderSortKey(value:int):void
      {
         _RenderSortKey = value;
      }
      
      [EditorData(ignore="true")]
      public function get renderCacheKey():int
      {
         return _RenderCacheKey;
      }
      
      public function set renderCacheKey(value:int):void
      {
         _RenderCacheKey = value;
      }

      public function invalidateRenderCache():void
      {
         _RenderCacheKey = RenderCacheKeyManager.Token++;
      }

      /**
       * @inheritDoc
       */
      public function get layerIndex():int
      {
         return _LayerIndex;
      }
      
      /**
       * @inheritDoc
       */
      public function set layerIndex(value:int):void
      {
         _LayerIndex = value;
      }
      
      /**
       * @inheritDoc
       */
      public function get renderPosition():Point
      {
         var position:Point = owner.getProperty(PositionReference);
         
         if (!position)
            return new Point(0, 0);
         
         return position.add(PositionOffset);
      }
      
      public function get renderScale():Point
      {
         var scale:Point = owner.getProperty(SizeReference);
         
         if(!scale)
            return new Point(1,1);
         
         return scale;
      }
      
      /**
       * @inheritDoc
       */
      public function onDraw(manager:IDrawManager2D):void
      {
         throw new Error("Derived classes must implement this method!");
      }
      
      private var _LayerIndex:int, _RenderSortKey:int, _RenderCacheKey:int;
   }
}