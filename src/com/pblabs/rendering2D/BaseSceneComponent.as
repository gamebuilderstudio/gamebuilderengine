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
   import com.pblabs.engine.core.Global;
   import com.pblabs.engine.core.IAnimatedObject;
   import com.pblabs.engine.core.ObjectType;
   import com.pblabs.engine.core.ProcessManager;
   import com.pblabs.engine.debug.Logger;
   import com.pblabs.engine.debug.Profiler;
   import com.pblabs.engine.entity.EntityComponent;
   import com.pblabs.engine.entity.IEntityComponent;
   import com.pblabs.engine.serialization.TypeUtility;
   import com.pblabs.rendering2D.ui.IUITarget;
   
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.StageQuality;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;

  /**
   * Base class that implements useful functionality for draw managers.
   */
   [EditorData(ignore="true")]
   public class BaseSceneComponent extends EntityComponent implements IAnimatedObject, IDrawManager2D
   {
      /**
       * The number of layers to create for each scene.
       */
      public static const LAYER_COUNT:int = 16;
      
      /**
       * Enables smooth rendering of bitmaps.
       */
      [EditorData(defaultValue="true")]
      public var smoothing:Boolean = true;
      
      /**
       * The display object to render scene content in to. In most cases this will be
       * set to an instance of either FlexSceneView or SceneView
       * 
       * @see com.pblabs.rendering2D.ui.FlexSceneView
       * @see com.pblabs.rendering2D.ui.SceneView
       */
      [EditorData(ignore="true")]
      public function get sceneView():IUITarget
      {
         if (_sceneView)
            return _sceneView;
         
         if (_sceneViewName)
            _sceneView = Global.findChild(_sceneViewName) as IUITarget;
         
         return _sceneView;
      }
      
      /**
       * @private
       */
      public function set sceneView(value:IUITarget):void
      {
         _sceneView = value;
      }
      
      /**
       * Sets the name of the component on the application to use as the scene view.
       */
      public function set sceneViewName(value:String):void
      {
         _sceneViewName = value;
         _sceneView = null;
      }
      
      /**
       * @private
       */
      [EditorData(defaultValue="MainView")]
      public function get sceneViewName():String
      {
         return _sceneViewName;
      }
      
      /**
       * @inheritDoc
       */
      public function get lastDrawnItem():IDrawable2D
      {
         return _lastDrawn;
      }
      
      /**
       * @inheritDoc
       */
      public function get nextDrawnItem():IDrawable2D
      {
         return _NextDrawn;
      }
      
      /**
       * Reference to the spatial database for this scene.
       */
      [EditorData(referenceType="componentReference")]
      public var spatialDatabase:ISpatialManager2D;
      
      /**
       * Types of objects that will be considered for rendering.
       */
      public var renderMask:ObjectType;
      
      /**
       * Array of layers that should be cached to a bitmap. Set the value at the layer
       * index to true to enable caching for that layer. Caching should only be enabled
       * on layers that are static or almost static. In the 'almost' case, call InvalidateLayerCache
       * on the layer to force it to redraw.
       */
      [TypeHint(type="Boolean")]
      public var cacheLayers:Array = new Array(LAYER_COUNT);
      
      private var _cacheLayerKey:Array = new Array(LAYER_COUNT);

      /**
       * @inheritDoc
       */
      public function onFrame(elapsed:Number):void
      {
         var oldQuality:String = Global.mainStage.quality;
         Global.mainStage.quality = StageQuality.LOW;
         render();
         Global.mainStage.quality = oldQuality;
      }
      
      /**
       * @inheritDoc
       */
      public function transformWorldToScreen(p:Point, altitude:Number=0):Point
      {
         throw new Error("Derived classes must implement this method!");
         return null;
      }
      
      /**
       * @inheritDoc
       */
      public function transformScreenToWorld(p:Point):Point
      {
         throw new Error("Derived classes must implement this method!");
         return null;
      }
      
      /**
       * @inheritDoc
       */
      public function drawDisplayObject(object:DisplayObject):void
      {
         if (!_currentRenderTarget)
            sceneView.addDisplayObject(object);
         else
            _currentRenderTarget.draw(object, object.transform.matrix, object.transform.colorTransform);
      }
      
      public function copyPixels(bitmapData:BitmapData, offset:Point):void
      {
         _currentRenderTarget.copyPixels(bitmapData, bitmapData.rect, offset);         
      }
      
      /**
       * @inheritDoc
       */
      public function drawBitmapData(bitmapData:BitmapData, matrix:Matrix):void
      {
         // If we have no matrix + it's to a bitmap target, we can copyPixels.
         if(!matrix && _currentRenderTarget)
         {
            Profiler.enter("DBD_CopyPixelsPath");
            _currentRenderTarget.copyPixels(bitmapData, bitmapData.rect, new Point(0,0));
            Profiler.exit("DBD_CopyPixelsPath");
            return;
         }
         
         // Make a dummy matrix if none is provided.
         if(!matrix)
            matrix = new Matrix();
            
         if (!_currentRenderTarget)
         {
            // Make a dummy sprite and draw into it.
            var bitmap:Bitmap = new Bitmap(bitmapData, "auto", smoothing);
            bitmap.transform.matrix = matrix;
            drawDisplayObject(bitmap);
         }
         else
         {
            Profiler.enter("DBD_BitmapPath");
            _currentRenderTarget.draw(bitmapData, matrix);
            Profiler.exit("DBD_BitmapPath");
         }
      }
      
      /**
       * @inheritDoc
       */
      public function getBackBuffer():BitmapData
      {
         return _currentRenderTarget;
      }
      
      /**
       * @inheritDoc
       */
      public function addAlwaysDrawnItem(item:IDrawable2D):void
      {
      	 // Only add the item to be drawn if it's not already in the AlwaysRender list
      	 if (_alwaysDrawnList.indexOf(item) == -1)
      	 {
            _alwaysDrawnList.push(item);
         }
      }
      
      /**
       * @inheritDoc
       */
      public function removeAlwaysDrawnItem(item:IDrawable2D):void
      {
         var index:int = _alwaysDrawnList.indexOf(item);
         if (index == -1)
         {
            Logger.printWarning(this, "RemoveInterstitialDrawer", "The object isn't in the always draw list");
            return;
         }
         
         _alwaysDrawnList.splice(index, 1);
      }
      
      /**
       * @inheritDoc
       */
      public function addInterstitialDrawer(object:IDrawable2D):void
      {
         _interstitialDrawnList.push(object);
      }
      
      /**
       * @inheritDoc
       */
      public function removeInterstitialDrawer(object:IDrawable2D):void
      {
         var index:int = _interstitialDrawnList.indexOf(object);
         if (index == -1)
         {
            Logger.printWarning(this, "RemoveInterstitialDrawer", "The object isn't in the interstitial draw list");
            return;
         }
         
         _interstitialDrawnList.splice(index, 1);
      }
      
      /**
       * @inheritDoc
       */
      public function sortSpatials(items:Array):void
      {
         // No sorting for basic ortho case, as we would have to know layer indices
         // which ISpatialObject2D doesn't have... and I don't need it right now 
         // for Grunts. :) -- BJG
      }

      /**
       * If the specified layer should be cached to a bitmap, returns true.
       * 
       * @param layerIndex The layer to check.
       * 
       * @return True if the layer is marked to be cached, false otherwise.
       */ 
      /**
       * If the specified layer should be cached to a bitmap, returns true.
       */ 
      public function isLayerCached(layerIndex:int):Boolean
      {
         if (!cacheLayers[layerIndex])
            return false
         
         return cacheLayers[layerIndex];
      }
      
      /**
       * Destroys the cached data for a layer so it will be redrawn on the next frame.
       * 
       * @param layerIndex The layer to invalidate.
       */
      public function invalidateLayerCache(layerIndex:int):void
      {
         if (!isLayerCached(layerIndex))
            return;
         
         var bitmap:BitmapData = _layerCache[layerIndex] as BitmapData;
         if (!bitmap)
            return;
         
         bitmap.dispose();
         _layerCache[layerIndex] = null;
      }
      
      /**
       * Invalidates the cached data for all cached layers.
       */
      public function invalidateAllLayerCaches():void
      {
         for (var i:int = 0; i < LAYER_COUNT; i++)
            invalidateLayerCache(i);
      }
      
      /**
       * Checks if a cached layer needs to be drawn.
       * 
       * @param layerIndex The layer to check.
       * @param layerContents What's in the layer, if we know.
       * 
       * @return True if the layer should be drawn, false otherwise.
       */
      public function doesLayerNeedUpdate(layerIndex:int, layerContents:Array):Boolean
      {
         // Make sure we have a valid bitmap - no bitmap means no cache!
         if(!_layerCache[layerIndex])
            return true;

         // If it's not supposed to be cached, then needs an update.
         if(!isLayerCached(layerIndex))
            return true;
         
         // If contents are provided, check that everything is older than the
         // cache.
         Profiler.enter("CheckingLayerUpdateNeed");
         var oldCacheKey:int = _cacheLayerKey[layerIndex];
         for each(var d:IDrawable2D in layerContents)
            if(d.renderCacheKey != oldCacheKey)
            {
               Profiler.exit("CheckingLayerUpdateNeed");
               return true;
            }

         Profiler.exit("CheckingLayerUpdateNeed");
         
         // Nope, no update required!
         return false;
      } 
      
      /**
       * Gets the cached bitmap for the specified layer.
       * 
       * @param layerIndex The layer to get the cached bitmap for.
       * 
       * @return The cached bitmap for the specified layer.
       */
      public function getLayerCacheBitmap(layerIndex:int):BitmapData
      {
         if (!isLayerCached(layerIndex))
         {
            Logger.printError(this, "getLayerCacheBitmap", "Cannot get a cached layer for a layer that isn't being cached.");
            return null;
         }
         
         var bitmap:BitmapData = _layerCache[layerIndex] as BitmapData;
         
         // Make sure it is the size of our sprite.
         if (!bitmap || (bitmap.width != sceneView.width) || (bitmap.height != sceneView.height))
         {
            Profiler.enter("RegeneratingBitmap");

            // Dispose & regenerate the bitmap.
            if (bitmap)
               bitmap.dispose();
            
            bitmap = new BitmapData(sceneView.width, sceneView.height, true, 0x0);

            // Store it into the cache.
            _layerCache[layerIndex] = bitmap;

            Profiler.exit("RegeneratingBitmap");
         }

         return bitmap;
      }
      
      protected function render():void
      {
         throw new Error("Derived classes must implement this method!");
      }

      override protected function onAdd():void
      {
         ProcessManager.instance.addAnimatedObject(this, -10);
      }
      
      override protected function onRemove():void 
      {
         ProcessManager.instance.removeAnimatedObject(this);
         _sceneView = null;
      }
      
      protected function drawSortedLayers(layerList:Array):void
      {
         Profiler.enter("drawSortedLayers");
         
         // Lock for performance.
         if (_currentRenderTarget)
            _currentRenderTarget.lock();
         
         // Clear last/next state.
         _lastDrawn = _NextDrawn = null;
         
         var rtStack:BitmapData = _currentRenderTarget;
         var layerBitmap:BitmapData;
         
         for (var i:int = 0; i < layerList.length; i++)
         {
            // Skip if it contains nothing.
            if(!layerList[i] || layerList[i].length == 0)
               continue;

            Profiler.enter("PreCache");
            
            layerBitmap = null;
            
            if (isLayerCached(i))
            {
               // First check if we can reuse the cached image.
               if (!doesLayerNeedUpdate(i, layerList[i]))
               {
                  // Great, just draw it.
                  Profiler.enter("DrawBitmap");
                  drawLayerCacheBitmap(i);
                  Profiler.exit("DrawBitmap");
                  Profiler.exit("PreCache");
                  continue;
               }
               
               // We do need to update, so clear the bitmap and note that we
               // are drawing into it.
               layerBitmap = getLayerCacheBitmap(i);
               layerBitmap.fillRect(layerBitmap.rect, 0);
               _currentRenderTarget = layerBitmap;
               _currentRenderTarget.lock();
            }

            Profiler.exit("PreCache");
            
            _cacheLayerKey[i] = RenderCacheKeyManager.Token++;
            
            Profiler.enter("RenderLayer");

            for each (var r:IDrawable2D in layerList[i])
            {
               // Do interstitial callbacks.
               _lastDrawn = _NextDrawn;
               _NextDrawn = r;
               _interstitialDrawnList.every(interstitialEveryCallback);
               
               // Update the cache key.
               r.renderCacheKey = _cacheLayerKey[i]; 
               
               // Do the draw callback.
               var profKey:String = TypeUtility.getObjectClassName(r);
               Profiler.enter(profKey);
               r.onDraw(this);
               Profiler.exit(profKey);
            }
            
            Profiler.exit("RenderLayer");
            
            Profiler.enter("PostCache");

            if (isLayerCached(i))
            {
               _currentRenderTarget.unlock();

               // Restore render target.
               _currentRenderTarget = rtStack;
               
               // Render the cached bitmap.
               Profiler.enter("DrawBitmap");
               drawLayerCacheBitmap(i);
               Profiler.exit("DrawBitmap");
            }

            Profiler.exit("PostCache");
         }
         
         // Do final interstitial callback.
         if (_NextDrawn)
         {
            _lastDrawn = _NextDrawn;
            _NextDrawn = null;
            _interstitialDrawnList.every(drawItem);
         }

         // Clear last/next state.
         _lastDrawn = _NextDrawn = null;

         // Clean up render state.
         if (_currentRenderTarget)
            _currentRenderTarget.unlock();
         
         Profiler.exit("drawSortedLayers");
      }

      private function drawItem(item:IDrawable2D):void
      {
         item.onDraw(this);
      }
      
      private function interstitialEveryCallback(item:IDrawable2D):void 
      {
         item.onDraw(this); 
      }
      
      private function drawLayerCacheBitmap(layerIndex:int):void
      {
         var bitmap:BitmapData = getLayerCacheBitmap(layerIndex);
         drawBitmapData(bitmap, null);
      }
      
      /**
       * Given a region, query the specific spatial database and fill the layerList with
       * arrays containing the items to be drawn in each layer. Some scenes may contain
       * layers that need to interact differently in space.
       * 
       * @param spatialManager The spatial database that is used to find components that should be rendered. 
       * @param viewRect The rect that is passed to the spatial database's queryRectangle 
       *                 function.
       * @param layerList The jagged array that becomes populated with arrays of IDrawable2D components 
       *                  contained by the same entity that contains the spatial components found by the spatial 
       *                  database's queryRectangle. 
       *                  Each array at an index represents the the IDrawable2D components at the same layerIndex.
       *                  For example, all IDrawable2D components with a layerIndex of 0 (the default) are put 
       *                  in the array located at position 0.
       */ 
      protected function buildSpecificRenderList(spatialManager:ISpatialManager2D, viewRect:Rectangle, layerList:Array):void
      {
         Profiler.enter("buildRenderList");
         
         // Get a list of the items that will be rendered.
         var renderList:Array = new Array();
         if(!spatialManager 
            || !spatialManager.queryRectangle(viewRect, renderMask, renderList))
         {
            // Nothing to draw.
            Profiler.exit("buildRenderList");
            return;
         }
         
         // Iterate over everything and stuff drawables into the right layers.
         for each (var object:IEntityComponent in renderList)
         {
            var renderableList:Array = object.owner.lookupComponentsByType(IDrawable2D);
            for each (var renderable:IDrawable2D in renderableList)
            {
               if (!layerList[renderable.layerIndex])
                  layerList[renderable.layerIndex] = new Array();
               
               layerList[renderable.layerIndex].push(renderable);
            }
         }
           
         // Deal with always-drawn stuff.
         for each (var alwaysRenderable:IDrawable2D in _alwaysDrawnList)
         {
            if (!layerList[alwaysRenderable.layerIndex])
               layerList[alwaysRenderable.layerIndex] = new Array();
            
            layerList[alwaysRenderable.layerIndex].push(alwaysRenderable);
         }

         Profiler.exit("buildRenderList");
      }
      
      /**
       * Given a region, query the spatialDatabase and fill the layerList with
       * arrays containing the items to be drawn in each layer.
       * 
       * @param viewRect The rect that is passed to the spatial database's queryRectangle 
       *                 function.
       * @param layerList The jagged array that becomes populated with arrays of IDrawable2D components 
       *                  contained by the same entity that contains the spatial components found by the spatial 
       *                  database's queryRectangle. 
       *                  Each array at an index contains the IDrawable2D components at the same layerIndex.
       *                  For example, all IDrawable2D components with a layerIndex of 0 (the default) are put 
       *                  in the array located at position 0.
       */ 
      protected function buildRenderList(viewRect:Rectangle, layerList:Array):void
      {
          buildSpecificRenderList(spatialDatabase, viewRect, layerList);
      }
      

      /**
       * When set, we render into the specified bitmapdata.
       */ 
      protected var _currentRenderTarget:BitmapData = null;
      private var _sceneView:IUITarget = null;
      private var _sceneViewName:String = "MainView";
      
      private var _alwaysDrawnList:Array = new Array();
      private var _interstitialDrawnList:Array = new Array();
      /**
       * Cached bitmaps from each layer, indexed by layer.
       */ 
      private var _layerCache:Array = new Array(LAYER_COUNT);
      
      private var _lastDrawn:IDrawable2D, _NextDrawn:IDrawable2D;
   }
}
