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
    * Minimal functionality in order to be drawn by the IDrawManager2D.
    */  
   public interface IDrawable2D
   {
      /**
       * Report the center position of this object as used for rendering.
       * 
       * @note We could use ISpatialObject2D here, but rendering may occur at
       *       an offset or based on interpolation. This can be trivially
       *       implemented using the same property fetch you use to place
       *       your rendering.
       */ 
      function get renderPosition():Point;
      
      /**
       * Objects are sorted by layer, and this is the index of this object's layer.
       */
      function get layerIndex():int;

      /**
       * Expose a sort key. This integer is used for general sorting logic.
       */
      function get renderSortKey():int;
      
      /**
       * @private
       */ 
      function set renderSortKey(value:int):void;
      
      /**
       * Expose a cache key. This integer is used to detect when a display layer
       * cache has been invalidated.
       */
      function set renderCacheKey(value:int):void;
      function get renderCacheKey():int;
      
      /**
       * When called, update the cache key so we force a redraw.
       */ 
      function invalidateRenderCache():void; 

      /**
       * Callback during rendering to give the object an opportunity to give the
       * IDrawManager2D stuff to display.
       * 
       * @see IDrawManager2D.DrawDisplayObject
       * @see IDrawManager2D.DrawBitmapData
       */ 
      function onDraw(manager:IDrawManager2D):void;
   }
}