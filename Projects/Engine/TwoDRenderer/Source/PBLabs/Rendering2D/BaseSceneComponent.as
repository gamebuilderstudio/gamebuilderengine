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
   import PBLabs.Engine.Core.*;
   import PBLabs.Engine.Debug.*;
   import PBLabs.Engine.Serialization.TypeUtility;
   import PBLabs.Engine.Entity.EntityComponent;
   import PBLabs.Engine.Entity.IEntityComponent;
   import PBLabs.Rendering2D.UI.IUITarget;
   
   import flash.display.*;
   import flash.geom.*;
   
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
      public var Smoothing:Boolean = true;
      
      /**
       * The display object to render scene content in to. In most cases this will be
       * set to an instance of either FlexSceneView or SceneView
       * 
       * @see PBLabs.Rendering2D.UI.FlexSceneView
       * @see PBLabs.Rendering2D.UI.SceneView
       */
      [EditorData(ignore="true")]
      public function get SceneView():IUITarget
      {
         if (_SceneView != null)
            return _SceneView;
         
         if (_SceneViewName != null)
            _SceneView = Global.FindChild(_SceneViewName) as IUITarget;
         
         return _SceneView;
      }
      
      /**
       * @private
       */
      public function set SceneView(value:IUITarget):void
      {
         _SceneView = value;
      }
      
      /**
       * Sets the name of the component on the application to use as the scene view.
       */
      public function set SceneViewName(value:String):void
      {
         _SceneViewName = value;
         _SceneView = null;
      }
      
      /**
       * @private
       */
      [EditorData(defaultValue="MainView")]
      public function get SceneViewName():String
      {
         return _SceneViewName;
      }
      
      /**
       * @inheritDoc
       */
      public function get LastDrawnItem():IDrawable2D
      {
         return _LastDrawn;
      }
      
      /**
       * @inheritDoc
       */
      public function get NextDrawnItem():IDrawable2D
      {
         return _NextDrawn;
      }
      
      /**
       * Reference to the spatial database for this scene.
       */
      [EditorData(referenceType="componentReference")]
      public var SpatialDatabase:ISpatialManager2D;
      
      /**
       * Types of objects that will be considered for rendering.
       */
      public var RenderMask:ObjectType;
      
      /**
       * Array of layers that should be cached to a bitmap. Set the value at the layer
       * index to true to enable caching for that layer. Caching should only be enabled
       * on layers that are static or almost static. In the 'almost' case, call InvalidateLayerCache
       * on the layer to force it to redraw.
       */
      [TypeHint(type="Boolean")]
      public var CacheLayers:Array = new Array(LAYER_COUNT);
      
      private var _CacheLayerKey:Array = new Array(LAYER_COUNT);

      /**
       * @inheritDoc
       */
      public function OnFrame(elapsed:Number):void
      {
         var oldQuality:String = Global.MainStage.quality;
         Global.MainStage.quality = StageQuality.LOW;
         _Render();
         Global.MainStage.quality = oldQuality;
      }
      
      /**
       * @inheritDoc
       */
      public function TransformWorldToScreen(p:Point, altitude:Number=0):Point
      {
         throw new Error("Derived classes must implement this method!");
         return null;
      }
      
      /**
       * @inheritDoc
       */
      public function TransformScreenToWorld(p:Point):Point
      {
         throw new Error("Derived classes must implement this method!");
         return null;
      }
      
      /**
       * @inheritDoc
       */
      public function DrawDisplayObject(object:DisplayObject):void
      {
         if (_CurrentRenderTarget == null)
            SceneView.AddDisplayObject(object);
         else
            _CurrentRenderTarget.draw(object, object.transform.matrix, object.transform.colorTransform);
      }
      
      /**
       * @inheritDoc
       */
      public function DrawBitmapData(bitmapData:BitmapData, matrix:Matrix):void
      {
         // If we have no matrix + it's to a bitmap target, we can copyPixels.
         if(!matrix && _CurrentRenderTarget)
         {
            Profiler.Enter("DBD_CopyPixelsPath");
            _CurrentRenderTarget.copyPixels(bitmapData, bitmapData.rect, new Point(0,0));
            Profiler.Exit("DBD_CopyPixelsPath");
            return;
         }
          
         // Make a dummy matrix if none is provided.
         if(!matrix)
            matrix = new Matrix();
            
         if (_CurrentRenderTarget == null)
         {
            // Make a dummy sprite and draw into it.
            var bitmap:Bitmap = new Bitmap(bitmapData, "auto", Smoothing);
            bitmap.transform.matrix = matrix;
            DrawDisplayObject(bitmap);
         }
         else
         {
            Profiler.Enter("DBD_BitmapPath");
            _CurrentRenderTarget.draw(bitmapData, matrix);
            Profiler.Exit("DBD_BitmapPath");
         }
      }
      
      /**
       * @inheritDoc
       */
      public function GetBackBuffer():BitmapData
      {
         return _CurrentRenderTarget;
      }
      
      /**
       * @inheritDoc
       */
      public function AddAlwaysDrawnItem(item:IDrawable2D):void
      {
         _AlwaysDrawnList.push(item);
      }
      
      /**
       * @inheritDoc
       */
      public function RemoveAlwaysDrawnItem(item:IDrawable2D):void
      {
         var index:int = _AlwaysDrawnList.indexOf(item);
         if (index == -1)
         {
            Logger.PrintWarning(this, "RemoveInterstitialDrawer", "The object isn't in the always draw list");
            return;
         }
         
         _AlwaysDrawnList.splice(index, 1);
      }
      
      /**
       * @inheritDoc
       */
      public function AddInterstitialDrawer(object:IDrawable2D):void
      {
         _InterstitialDrawnList.push(object);
      }
      
      /**
       * @inheritDoc
       */
      public function RemoveInterstitialDrawer(object:IDrawable2D):void
      {
         var index:int = _InterstitialDrawnList.indexOf(object);
         if (index == -1)
         {
            Logger.PrintWarning(this, "RemoveInterstitialDrawer", "The object isn't in the interstitial draw list");
            return;
         }
         
         _InterstitialDrawnList.splice(index, 1);
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
      public function IsLayerCached(layerIndex:int):Boolean
      {
         if (CacheLayers[layerIndex] == null)
            return false
         
         return CacheLayers[layerIndex];
      }
      
      /**
       * Destroys the cached data for a layer so it will be redrawn on the next frame.
       * 
       * @param layerIndex The layer to invalidate.
       */
      public function InvalidateLayerCache(layerIndex:int):void
      {
         if (!IsLayerCached(layerIndex))
            return;
         
         var bitmap:BitmapData = _LayerCache[layerIndex] as BitmapData;
         if (bitmap == null)
            return;
         
         bitmap.dispose();
         _LayerCache[layerIndex] = null;
      }
      
      /**
       * Invalidates the cached data for all cached layers.
       */
      public function InvalidateAllLayerCaches():void
      {
         for (var i:int = 0; i < LAYER_COUNT; i++)
            InvalidateLayerCache(i);
      }
      
      /**
       * Checks if a cached layer needs to be drawn.
       * 
       * @param layerIndex The layer to check.
       * @param layerContents What's in the layer, if we know.
       * 
       * @return True if the layer should be drawn, false otherwise.
       */
      public function DoesLayerNeedUpdate(layerIndex:int, layerContents:Array):Boolean
      {
         // Make sure we have a valid bitmap - no bitmap means no cache!
         if(!_LayerCache[layerIndex])
            return true;

         // If it's not supposed to be cached, then needs an update.
         if(!IsLayerCached(layerIndex))
            return true;
         
         // If contents are provided, check that everything is older than the
         // cache.
         Profiler.Enter("CheckingLayerUpdateNeed");
         var oldCacheKey:int = _CacheLayerKey[layerIndex];
         for each(var d:IDrawable2D in layerContents)
            if(d.RenderCacheKey != oldCacheKey)
            {
               Profiler.Exit("CheckingLayerUpdateNeed");
               return true;
            }

         Profiler.Exit("CheckingLayerUpdateNeed");
         
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
      public function GetLayerCacheBitmap(layerIndex:int):BitmapData
      {
         if (!IsLayerCached(layerIndex))
         {
            Logger.PrintError(this, "GetLayerCacheBitmap", "Cannot get a cached layer for a layer that isn't being cached.");
            return null;
         }
         
         var bitmap:BitmapData = _LayerCache[layerIndex] as BitmapData;
         
         // Make sure it is the size of our sprite.
         if (!bitmap || (bitmap.width != SceneView.width) || (bitmap.height != SceneView.height))
         {
            Profiler.Enter("RegeneratingBitmap");

            // Dispose & regenerate the bitmap.
            if (bitmap)
               bitmap.dispose();
            
            bitmap = new BitmapData(SceneView.width, SceneView.height, true, 0x0);

            // Store it into the cache.
            _LayerCache[layerIndex] = bitmap;

            Profiler.Exit("RegeneratingBitmap");
         }

         return bitmap;
      }
      
      protected function _Render():void
      {
         throw new Error("Derived classes must implement this method!");
      }

      protected override function _OnAdd():void
      {
         ProcessManager.Instance.AddAnimatedObject(this, -10);
      }
      
      protected override function _OnRemove():void 
      {
         ProcessManager.Instance.RemoveAnimatedObject(this);
         _SceneView = null;
      }
      
      protected function _DrawSortedLayers(layerList:Array):void
      {
         Profiler.Enter("_DrawSortedLayers");
         
         // Lock for performance.
         if (_CurrentRenderTarget)
            _CurrentRenderTarget.lock();
         
         // Clear last/next state.
         _LastDrawn = _NextDrawn = null;
         
         var rtStack:BitmapData = _CurrentRenderTarget;
         var layerBitmap:BitmapData;
         
         for (var i:int = 0; i < layerList.length; i++)
         {
            // Skip if it contains nothing.
            if(!layerList[i] || layerList[i].length == 0)
               continue;

            Profiler.Enter("PreCache");
            
            layerBitmap = null;
            
            if (IsLayerCached(i))
            {
               // First check if we can reuse the cached image.
               if (!DoesLayerNeedUpdate(i, layerList[i]))
               {
                  // Great, just draw it.
                  Profiler.Enter("DrawBitmap");
                  _DrawLayerCacheBitmap(i);
                  Profiler.Exit("DrawBitmap");
                  Profiler.Exit("PreCache");
                  continue;
               }
               
               // We do need to update, so clear the bitmap and note that we
               // are drawing into it.
               layerBitmap = GetLayerCacheBitmap(i);
               layerBitmap.fillRect(layerBitmap.rect, 0);
               _CurrentRenderTarget = layerBitmap;
               _CurrentRenderTarget.lock();
            }

            Profiler.Exit("PreCache");
            
            _CacheLayerKey[i] = RenderCacheKeyManager.Token++;
            
            Profiler.Enter("RenderLayer");

            for each (var r:IDrawable2D in layerList[i])
            {
               // Do interstitial callbacks.
               _LastDrawn = _NextDrawn;
               _NextDrawn = r;
               _InterstitialDrawnList.every(_InterstitialEveryCallback);
               
               // Update the cache key.
               r.RenderCacheKey = _CacheLayerKey[i]; 
               
               // Do the draw callback.
               var profKey:String = TypeUtility.GetObjectClassName(r);
               Profiler.Enter(profKey);
               r.OnDraw(this);
               Profiler.Exit(profKey);
            }
            
            Profiler.Exit("RenderLayer");
            
            Profiler.Enter("PostCache");

            if (IsLayerCached(i))
            {
               _CurrentRenderTarget.unlock();

               // Restore render target.
               _CurrentRenderTarget = rtStack;
               
               // Render the cached bitmap.
               Profiler.Enter("DrawBitmap");
               _DrawLayerCacheBitmap(i);
               Profiler.Exit("DrawBitmap");
            }

            Profiler.Exit("PostCache");
         }
         
         // Do final interstitial callback.
         if (_NextDrawn)
         {
            _LastDrawn = _NextDrawn;
            _NextDrawn = null;
            _InterstitialDrawnList.every(function(item:IDrawable2D):void { item.OnDraw(this); });            
         }

         // Clear last/next state.
         _LastDrawn = _NextDrawn = null;

         // Clean up render state.
         if (_CurrentRenderTarget)
            _CurrentRenderTarget.unlock();
         
         Profiler.Exit("_DrawSortedLayers");
      }
      
      private function _InterstitialEveryCallback(item:IDrawable2D):void 
      {
         item.OnDraw(this); 
      }
      
      private function _DrawLayerCacheBitmap(layerIndex:int):void
      {
         var bitmap:BitmapData = GetLayerCacheBitmap(layerIndex);
         DrawBitmapData(bitmap, null);
      }
      
      /**
       * Given a region, query the spatial database and fill the layerList with
       * arrays containing the items to be drawn in each layer.
       */ 
      protected function _BuildRenderList(viewRect:Rectangle, layerList:Array):void
      {
         Profiler.Enter("_BuildRenderList");
         
         // Get a list of the items that will be rendered.
         var renderList:Array = new Array();
         if(!SpatialDatabase 
            || !SpatialDatabase.QueryRectangle(viewRect, RenderMask, renderList))
         {
            // Nothing to draw.
            Profiler.Exit("_BuildRenderList");
            return;
         }
         
         // Iterate over everything and stuff drawables into the right layers.
         for each (var object:IEntityComponent in renderList)
         {
            var renderableList:Array = object.Owner.LookupComponentsByType(IDrawable2D);
            for each (var renderable:IDrawable2D in renderableList)
            {
               if (layerList[renderable.LayerIndex] == null)
                  layerList[renderable.LayerIndex] = new Array();
               
               layerList[renderable.LayerIndex].push(renderable);
            }
         }
           
         // Deal with always-drawn stuff.
         for each (var alwaysRenderable:IDrawable2D in _AlwaysDrawnList)
         {
            if (layerList[alwaysRenderable.LayerIndex] == null)
               layerList[alwaysRenderable.LayerIndex] = new Array();
            
            layerList[alwaysRenderable.LayerIndex].push(alwaysRenderable);
         }

         Profiler.Exit("_BuildRenderList");
      }
      

      /**
       * When set, we render into the specified bitmapdata.
       */ 
      protected var _CurrentRenderTarget:BitmapData = null;
      private var _SceneView:IUITarget = null;
      private var _SceneViewName:String = "MainView";
      
      private var _AlwaysDrawnList:Array = new Array();
      private var _InterstitialDrawnList:Array = new Array();
      /**
       * Cached bitmaps from each layer, indexed by layer.
       */ 
      private var _LayerCache:Array = new Array(LAYER_COUNT);
      
      private var _LastDrawn:IDrawable2D, _NextDrawn:IDrawable2D;
   }
}
