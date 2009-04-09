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
   import PBLabs.Engine.Entity.EntityComponent;
   import PBLabs.Engine.Entity.IEntityComponent;
   import PBLabs.Engine.Core.*;
   import PBLabs.Engine.Debug.Logger;
   
   import flash.display.*;
   import flash.events.Event;
   import flash.geom.*;
   
  /**
   * Base class that implements useful functionality for draw managers.
   */
   public class BaseSceneComponent extends EntityComponent implements IAnimatedObject, IDrawManager2D
   {
      /**
       * The number of layers to create for each scene.
       */
      public static const LAYER_COUNT:int = 64;
      
      /**
       * The display object to render scene content in to. In most cases this will be
       * set to an instance of either FlexSceneView or SceneView
       * 
       * @see PBLabs.Rendering2D.UI.FlexSceneView
       * @see PBLabs.Rendering2D.UI.SceneView
       */
      public function get SceneView():DisplayObjectContainer
      {
         if (_sceneView != null)
            return _sceneView;
         
         if (_sceneViewName != null)
            _sceneView = Global.FindChild(_sceneViewName) as DisplayObjectContainer;
         
         return _sceneView;
      }
      
      /**
       * @private
       */
      public function set SceneView(value:DisplayObjectContainer):void
      {
         _sceneView = value;
      }
      
      /**
       * Sets the name of the component on the application to use as the scene view.
       */
      public function set SceneViewName(value:String):void
      {
         _sceneViewName = value;
         _sceneView = null;
      }
      
      /**
       * @private
       */
      public function get SceneViewName():String
      {
         return _sceneViewName;
      }
      
      /**
       * @inheritDoc
       */
      public function get LastDrawnItem():IDrawable2D
      {
         return _lastDrawn;
      }
      
      /**
       * @inheritDoc
       */
      public function get NextDrawnItem():IDrawable2D
      {
         return _nextDrawn;
      }
      
      /**
       * Reference to the spatial database for this scene.
       */
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
      public var CacheLayers:Array = new Array(LAYER_COUNT);
      
      /**
       * @inheritDoc
       */
      public function OnFrame(elapsed:Number):void
      {
         _Render();
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
         if (_currentRenderTarget == null)
            SceneView.addChild(object);
         else
            _currentRenderTarget.draw(object, object.transform.matrix);
      }
      
      /**
       * @inheritDoc
       */
      public function DrawBitmapData(bitmap:BitmapData, matrix:Matrix):void
      {
         if (_currentRenderTarget == null)
         {
            // Make a dummy sprite and draw into it.
            var dummy:Sprite = new Sprite();
            dummy.graphics.beginBitmapFill(bitmap);
            dummy.graphics.drawRect(0, 0, bitmap.width, bitmap.height);
            dummy.graphics.endFill();
            dummy.transform.matrix = matrix;
            
            DrawDisplayObject(dummy);            
         }
         else
         {
            _currentRenderTarget.draw(bitmap, matrix);
         }
      }
      
      /**
       * @inheritDoc
       */
      public function GetBackBuffer():BitmapData
      {
         return _currentRenderTarget;
      }
      
      /**
       * @inheritDoc
       */
      public function AddAlwaysDrawnItem(item:IDrawable2D):void
      {
         _alwaysDrawnList.push(item);
      }
      
      /**
       * @inheritDoc
       */
      public function RemoveAlwaysDrawnItem(item:IDrawable2D):void
      {
         var index:int = _alwaysDrawnList.indexOf(item);
         if (index == -1)
         {
            Logger.PrintWarning(this, "RemoveInterstitialDrawer", "The object isn't in the always draw list");
            return;
         }
         
         _alwaysDrawnList.splice(index, 1);
      }
      
      /**
       * @inheritDoc
       */
      public function AddInterstitialDrawer(object:IDrawable2D):void
      {
         _interstitialDrawnList.push(object);
      }
      
      /**
       * @inheritDoc
       */
      public function RemoveInterstitialDrawer(object:IDrawable2D):void
      {
         var index:int = _interstitialDrawnList.indexOf(object);
         if (index == -1)
         {
            Logger.PrintWarning(this, "RemoveInterstitialDrawer", "The object isn't in the interstitial draw list");
            return;
         }
         
         _interstitialDrawnList.splice(index, 1);
      }
      
      /**
       * If the specified layer should be cached to a bitmap, returns true.
       * 
       * @param layerIndex The layer to check.
       * 
       * @return True if the layer is marked to be cached, false otherwise.
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
         
         var bitmap:BitmapData = _layerCache[layerIndex] as BitmapData;
         if (bitmap == null)
            return;
         
         bitmap.dispose();
         _layerCache[layerIndex] = null;
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
       * 
       * @return True if the layer should be drawn, false otherwise.
       */
      public function DoesLayerNeedUpdate(layerIndex:int):Boolean
      {
         if (!IsLayerCached(layerIndex))
            return false;
         
         if (_layerCache[layerIndex] == null)
            return true;
         
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
         
         var bitmap:BitmapData = _layerCache[layerIndex] as BitmapData;
         
         // Make sure it is the size of our sprite.
         if (!bitmap || (bitmap.width != SceneView.width) || (bitmap.height != SceneView.height))
         {
            // Dispose & regenerate the bitmap.
            if (bitmap)
               bitmap.dispose();
            
            bitmap = new BitmapData(SceneView.width, SceneView.height, true, 0x0);

            // Store it into the cache.
            _layerCache[layerIndex] = bitmap;
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
         _sceneView = null;
      }
      
      protected function _DrawSortedLayers(layerList:Array):void
      {
         // Lock for performance.
         if (_currentRenderTarget)
            _currentRenderTarget.lock();
         
         // Clear last/next state.
         _lastDrawn = _nextDrawn = null;
         
         var rtStack:BitmapData = _currentRenderTarget;
         var layerBitmap:BitmapData;
         
         for (var i:int = 0; i < layerList.length; i++)
         {
            layerBitmap = null;
            
            if (IsLayerCached(i))
            {
               // First check if we can reuse the cached image.
               if (!DoesLayerNeedUpdate(i))
               {
                  // Great, just draw it.
                  _DrawLayerCacheBitmap(i);
                  continue;
               }
               
               // We do need to update, so clear the bitmap and note that we
               // are drawing into it.
               layerBitmap = GetLayerCacheBitmap(i);
               layerBitmap.fillRect(layerBitmap.rect, 0);
               _currentRenderTarget = layerBitmap;
            }

            for each (var r:IDrawable2D in layerList[i])
            {
               // Do interstitial callbacks.
               _lastDrawn = _nextDrawn;
               _nextDrawn = r;
               _interstitialDrawnList.every(function(item:IDrawable2D):void { item.OnDraw(this); });
               
               // Do the draw callback.
               r.OnDraw(this);
            }
            
            if (IsLayerCached(i))
            {
               // Restore render target.
               _currentRenderTarget = rtStack;
               
               // Render the cached bitmap.
               _DrawLayerCacheBitmap(i);
            }
         }
         
         // Do final interstitial callback.
         if (_nextDrawn)
         {
            _lastDrawn = _nextDrawn;
            _nextDrawn = null;
            _interstitialDrawnList.every(function(item:IDrawable2D):void { item.OnDraw(this); });            
         }

         // Clear last/next state.
         _lastDrawn = _nextDrawn = null;

         // Clean up render state.
         if (_currentRenderTarget)
            _currentRenderTarget.unlock();
      }
      
      private function _DrawLayerCacheBitmap(layerIndex:int):void
      {
         var bitmap:BitmapData = GetLayerCacheBitmap(layerIndex);
         DrawBitmapData(bitmap, null);
      }
      
      protected function _BuildRenderList(viewRect:Rectangle, layerList:Array):void
      {
         // Get a list of the items that will be rendered.
         var renderList:Array = new Array();
         if ((SpatialDatabase == null) || !SpatialDatabase.QueryRectangle(viewRect, RenderMask, renderList))
            return;
         
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
         for each (var alwaysRenderable:IDrawable2D in _alwaysDrawnList)
         {
            if (layerList[alwaysRenderable.LayerIndex] == null)
               layerList[alwaysRenderable.LayerIndex] = new Array();
            
            layerList[alwaysRenderable.LayerIndex].push(alwaysRenderable);
         }
      }
      
      protected var _currentRenderTarget:BitmapData = null;
      private var _sceneView:DisplayObjectContainer = null;
      private var _sceneViewName:String = null;
      
      private var _alwaysDrawnList:Array = new Array();
      private var _interstitialDrawnList:Array = new Array();
      private var _layerCache:Array = new Array(LAYER_COUNT);
      
      private var _lastDrawn:IDrawable2D, _nextDrawn:IDrawable2D;
   }
}
