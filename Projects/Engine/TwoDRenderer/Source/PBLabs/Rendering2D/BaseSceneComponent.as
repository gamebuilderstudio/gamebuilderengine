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
   
   import flash.display.*;
   import flash.events.Event;
   import flash.geom.*;
   
   import mx.core.Application;
   import mx.core.UIComponent;
   
  /**
   * Base class that implements useful functionality for draw managers.
   */
   public class BaseSceneComponent extends EntityComponent implements IAnimatedObject, IDrawManager2D
   {
      /**
       * How many layers will we have?
       */
      public static const LAYER_COUNT:int = 64;

      /**
       * Looks for a DisplayObject with this name in the Application to draw to.
       */ 
      public var SpriteName:String;

      /**
       * Reference to the spatial database for this scene.
       */  
      public var SpatialDatabase:ISpatialManager2D;
      
      /**
       * Types of objects that will be considered for rendering.
       */ 
      public var RenderMask:ObjectType;
      
      /**
       * Indexed by layer; if true then we cache to a bitmap.
       */
      public var CacheLayers:Array = new Array(LAYER_COUNT);

      public function OnFrame(elapsed:Number):void
      {
         Render();
      }
      
      protected function Render():void
      {
         throw new Error("Not implemented by base class.");
      }

      protected override function _OnAdd():void
      {
         if (Application.application.stage != null)
            _SetupSprite();
         else
            Application.application.addEventListener(Event.ADDED_TO_STAGE, _SetupSprite);
         
         ProcessManager.Instance.AddAnimatedObject(this, -10);
      }
      
      protected override function _OnRemove():void 
      {         
         // Only remove if we created it.
         if(!SpriteName)
            Application.application.stage.removeChild(_sprite);
         _sprite = null;

         ProcessManager.Instance.RemoveAnimatedObject(this);
      }

      /**
       * Get ahold of a DisplayObject to render to.
       */ 
      protected function _SetupSprite(event:Event=null):void
      {
         if(!SpriteName)
         {
            // Draw to something default.
            _sprite = Application.application.graphicsCanvas;
         }
         else
         {
            // We can reuse an existing sprite.
            _sprite = (Application.application as Application).getChildByName(SpriteName) as Sprite;
         }
      }
      
      /**
       * Given an array of arrays of IDrawable2Ds, draw them in the right order,
       * calling back on the interstitial drawer and updating state.
       */ 
      protected function _DrawSortedLayers(layerList:Array):void
      {
         // Lock for performance.
         if(_CurrentRenderTarget) _CurrentRenderTarget.lock();
         
         // Clear last/next state.
         _lastDrawn = _nextDrawn = null;
         
         var rtStack:BitmapData = _CurrentRenderTarget;
         var layerBitmap:BitmapData;
         
         for(var i:int=0; i<layerList.length; i++)
         {
            layerBitmap = null;
            
            if(IsLayerCached(i))
            {
               // First check if we can reuse the cached image.
               if(DoesLayerNeedUpdate(i) == false)
               {
                  // Great, just draw it.
                  DrawLayerCacheBitmap(i);
                  continue;
               }
               
               // We do need to update, so clear the bitmap and note that we
               // are drawing into it.
               layerBitmap = GetLayerCacheBitmap(i);
               layerBitmap.fillRect(layerBitmap.rect, 0);
               _CurrentRenderTarget = layerBitmap;
            }

            for each(var r:IDrawable2D in layerList[i])
            {
               // Do interstitial callbacks.
               _lastDrawn = _nextDrawn;
               _nextDrawn = r;
               _InterstitialDrawnList.every(function(item:IDrawable2D):void { item.OnDraw(this); });
               
               // Do the draw callback.
               r.OnDraw(this);
            }
            
            if(IsLayerCached(i))
            {
               // Restore render target.
               _CurrentRenderTarget = rtStack;
               
               // Render the cached bitmap.
               DrawLayerCacheBitmap(i);
            }
         }
         
         // Do final interstitial callback.
         if(_nextDrawn)
         {
               _lastDrawn = _nextDrawn;
               _nextDrawn = null;
               _InterstitialDrawnList.every(function(item:IDrawable2D):void { item.OnDraw(this); });            
         }

         // Clear last/next state.
         _lastDrawn = _nextDrawn = null;

         // Clean up render state.
         if(_CurrentRenderTarget) _CurrentRenderTarget.unlock();
      }
      
      /**
       * If the specified layer should be cached to a bitmap, returns true.
       */ 
      public function IsLayerCached(layerIndex:int):Boolean
      {
         return !(!CacheLayers[layerIndex]);
      }
      
      public function InvalidateLayerCache(layerIndex:int):void
      {
         if(!IsLayerCached(layerIndex))
            return;
         
         var bd:BitmapData = _LayerCache[layerIndex] as BitmapData;
         if(!bd)
            return;
         
         bd.dispose();
         _LayerCache[layerIndex] = null;
      }
      
      public function InvalidateAllLayerCaches():void
      {
         for(var i:int=0; i<LAYER_COUNT; i++)
            InvalidateLayerCache(i);
      }
     
      public function DoesLayerNeedUpdate(layerIndex:int):Boolean
      {
         if(!IsLayerCached(layerIndex))
            return false;
         
         if(!_LayerCache[layerIndex])
            return true;
         
         return false;
      } 
      
      public function GetLayerCacheBitmap(layerIndex:int):BitmapData
      {
         // Error if we aren't caching.
         if(!IsLayerCached(layerIndex))
            throw new Error("Cannot get cache bitmap for layer with no caching!");
         
         var bd:BitmapData = _LayerCache[layerIndex] as BitmapData;
         
         // Make sure it is the size of our sprite.
         if(!bd
            || bd.width != _sprite.width
            || bd.height != _sprite.height)
         {
            // Dispose & regenerate the bitmap.
            if(bd) bd.dispose();
            bd = new BitmapData(_sprite.width, _sprite.height, true, 0x0);

            // Store it into the cache.
            _LayerCache[layerIndex] = bd;
         }

         return bd;
      }
      
      private function DrawLayerCacheBitmap(layerIndex:int):void
      {
         var bd:BitmapData = GetLayerCacheBitmap(layerIndex);
         DrawBitmapData(bd, null);
      }
      
      /**
       * Given a region, query the spatial database and fill the layerList with
       * arrays containing the items to be drawn in each layer.
       */ 
      protected function _BuildRenderList(viewRect:Rectangle, layerList:Array):void
      {
         // Get a list of the items that will be rendered.
         var renderList:Array = new Array();
         if(!SpatialDatabase 
            || !SpatialDatabase.QueryRectangle(viewRect, RenderMask, renderList))
         {
            // Nothing to draw.
            return;
         }
         
         // Iterate over everything and stuff drawables into the right layers.
         for each(var obj2:IEntityComponent in renderList)
         {
            var renderableList:Array = obj2.Owner.LookupComponentsByType(IDrawable2D);
            for each(var r:IDrawable2D in renderableList)
            {
               if(!layerList[r.LayerIndex])
                  layerList[r.LayerIndex] = new Array();
               layerList[r.LayerIndex].push(r);
            }
         }
           
         // Deal with always-drawn stuff.
         for each(r in _AlwaysDrawnList)
         {
            if(!layerList[r.LayerIndex])
               layerList[r.LayerIndex] = new Array();
            layerList[r.LayerIndex].push(r);
         }
      }
            
      public virtual function TransformWorldToScreen(p:Point, altitude:Number=0):Point
      {
         throw new Error("Not implemented in base class.");
         return null;
      }
      
      public virtual function TransformScreenToWorld(p:Point):Point
      {
         throw new Error("Not implemented in base class.");
         return null;
      }
      
      public function get LastDrawnItem():IDrawable2D
      {
         return _lastDrawn;
      }
      
      public function get NextDrawnItem():IDrawable2D
      {
         return _nextDrawn;
      }
      
      public virtual function DrawDisplayObject(object:DisplayObject):void
      {
         if(_CurrentRenderTarget == null)
            (_sprite as DisplayObjectContainer).addChild(object);
         else
         {
            _CurrentRenderTarget.draw(object, object.transform.matrix);
         }
      }
      
      public virtual function DrawBitmapData(bd:BitmapData, m:Matrix):void
      {
         if(_CurrentRenderTarget == null)
         {
            // Make a dummy sprite and draw into it.
            var dummy:UIComponent = new UIComponent();
            dummy.graphics.beginBitmapFill(bd);
            dummy.graphics.drawRect(0, 0, bd.width, bd.height);
            dummy.graphics.endFill();
            dummy.transform.matrix = m;
            
            DrawDisplayObject(dummy);            
         }
         else
         {
            _CurrentRenderTarget.draw(bd, m);
         }
      }
      
      public virtual function GetBackBuffer():BitmapData
      {
         return _CurrentRenderTarget;
      }

      public function AddAlwaysDrawnItem(item:IDrawable2D):void
      {
         _AlwaysDrawnList.push(item);
      }
      
      public function RemoveAlwaysDrawnItem(item:IDrawable2D):void
      {
         var idx:int = _AlwaysDrawnList.indexOf(item);
         if(idx == -1)
            throw new Error("Could not find item in list.");
         _AlwaysDrawnList.splice(idx, 1);
      }
      
      public function AddInterstitialDrawer(obj:IDrawable2D):void
      {
         _InterstitialDrawnList.push(obj);
      }
      
      public function RemoveInterstitialDrawer(obj:IDrawable2D):void
      {
         var idx:int = _InterstitialDrawnList.indexOf(obj);
         if(idx == -1)
            throw new Error("Could not find item in list.");
         _InterstitialDrawnList.splice(idx, 1);
      }
      
      private var _AlwaysDrawnList:Array = new Array();
      private var _InterstitialDrawnList:Array = new Array();
      protected var _sprite:Sprite = null;
      
      private var _lastDrawn:IDrawable2D, _nextDrawn:IDrawable2D;

      /**
       * Cached bitmaps from each layer, indexed by layer.
       */ 
      private var _LayerCache:Array = new Array(LAYER_COUNT);

      /**
       * When set, we render into the specified bitmapdata.
       */ 
      protected var _CurrentRenderTarget:BitmapData = null;
   }
}
