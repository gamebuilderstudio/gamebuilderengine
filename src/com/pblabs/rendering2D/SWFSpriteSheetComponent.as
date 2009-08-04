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
    import com.pblabs.engine.resource.SWFResource;
    import flash.display.*;
    import flash.geom.*;

   /**
   * A class that is similar to the SpriteSheetComponent
   * except the frames are loaded by rasterizing a MovieClip 
   * rather than a single image. 
   */
   public class SWFSpriteSheetComponent extends SpriteContainerComponent
   {
      /**
      * The SWF to be rasterized into frames.
      */
      public function get swf():SWFResource
      {
         return _resource;
      }
      
      public function set swf(value:SWFResource):void
      {
         _resource = value;
         _frames = null;
         deleteFrames();
      }

      /**
      * The name of the clip to instantiate from the SWF.
      * If this is null the root clip will be used.
      */
      public function get clipName():String
      {
         return _clipName;
      }
      
      public function set clipName(value:String):void
      {
         _clipName = value;
         _frames = null;
         _clip = null;
         deleteFrames();
      }
      
      /**
      * Whether or not the bitmaps that are drawn should be smoothed. Default is True.
      */
      public function get smoothing():Boolean 
      {
         return _smoothing;
      }
      public function set smoothing(value:Boolean):void 
      {
         _smoothing = value;
      }
      
      override public function get isLoaded() : Boolean
      {
         if (!_resource) 
             return false;
         
         if (!_frames) 
            rasterize();
         
         return _frames != null;
      }
      
      /**
      * Rasterizes the associated Clip and returns a list of frames.
      */
      override protected function getSourceFrames() : Array
      {
         if (!_frames)
            rasterize();
         
         return _frames;
      }
      
      /**
      * Rasterizes the clip into an Array of BitmapData objects.
      * This array can then be used just like a sprite sheet.
      */
      protected function rasterize():void
      {
         if (_clipName)
         {
            _clip = _resource.getExportedAsset(_clipName) as MovieClip;
            if (!_clip)
               _clip = _resource.clip;
         }
         else
         {
            _clip = _resource.clip;
         }
            
         _frames = onRasterize(_clip);
      }

      /**
      * Performs the actual rasterizing. Override this to perform custom rasterizing of a clip.
      */
      protected function onRasterize(mc:MovieClip):Array
      {
         var maxFrames:int = findMaxFrames(mc, mc.totalFrames);
         var rasterized:Array = new Array(maxFrames);
          
         for(var i:int=1; i <= maxFrames; i++)
         {
            if (mc.totalFrames >= i)
               mc.gotoAndStop(i);

            advanceChildClips(mc, i);
            var bd:BitmapData = getBitmapDataByDisplay(mc);            
            rasterized[i - 1] = bd;
         }
         
         return rasterized;
      }
      
      /**
      * Recursively searches all child clips for the maximum frame count.
      * This becomes the number of frames that will be rasterized.
      */
      protected function findMaxFrames(parent:MovieClip, currentMax:int):int
      {
         for (var i:int=0; i < parent.numChildren; i++)
          {
            var mc:MovieClip = parent.getChildAt(i) as MovieClip;
            if(!mc)
               continue;
            
            currentMax = Math.max(currentMax, mc.totalFrames);            
            
            findMaxFrames(mc, currentMax);
         }
         
         return currentMax;
      }
      
      /**
      * Recursively advances all child clips to the current frame.
      * If the child does not have a frame at the current position, it is skipped.
      */
      protected function advanceChildClips(parent:MovieClip, currentFrame:int):void
      {
         for (var j:int=0; j<parent.numChildren; j++)
         {
            var mc:MovieClip = parent.getChildAt(j) as MovieClip;
            if(!mc)
               continue;

            if (mc.totalFrames >= currentFrame)
               mc.gotoAndStop(currentFrame);

            advanceChildClips(mc, currentFrame);
         }
      }

      /**
      * Draws the DisplayObject to a BitmapData using the bounds of the object. 
      */
      protected function getBitmapDataByDisplay(display:DisplayObject):BitmapData 
      {
         var bounds:Rectangle = display.getBounds(display);
         
         var bd:BitmapData = new BitmapData(
            Math.max(1, Math.min(2880, bounds.width)),
            Math.max(1, Math.min(2880, bounds.height)),
            _smoothing,
            0x00000000);
         
         bd.draw(display, new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y), null, null, null, _smoothing);
         
         return bd;
      }

      private var _smoothing:Boolean = true;
      private var _frames:Array;
      private var _resource:SWFResource;
      private var _clipName:String;
      private var _clip:MovieClip;
   }
}