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
   import com.pblabs.engine.entity.EntityComponent;
   import com.pblabs.engine.entity.PropertyReference;
   import com.pblabs.engine.core.ProcessManager;
   import com.pblabs.engine.debug.Logger;
   import com.pblabs.engine.math.Utility;
   
   import flash.display.*;
   import flash.geom.Matrix;
   import flash.geom.Point;

   /**
    * Simple render component that draws an image from a sprite sheet.
    */
   public class SpriteRenderComponent extends BaseRenderComponent
   {
      /**
       * The sprite sheet to use to draw this sprite.
       */
      public function get spriteSheet():SpriteSheetComponent
      {
         return _spriteSheet;
      }
      
      /**
       * @private
       */
      public function set spriteSheet(value:SpriteSheetComponent):void
      {
         _spriteSheet = value;
         _spriteDirty = true;
      }
      
      /**
       * The index in the sprite sheet of the frame to draw.
       */
      public function get spriteIndex():int
      {
         return _spriteIndex;
      }
      
      public function get rawSprite():DisplayObject
      {
         return _sprite;
      }
      
      /**
       * @private
       */
      public function set spriteIndex(value:int):void
      {
         _spriteIndex = value;
         _spriteDirty = true;
      }
      
      [EditorData(defaultValue="true")]
      public function get smoothing():Boolean
      {
         return _smoothing;
      }
      
      public function set smoothing(value:Boolean):void
      {
         _smoothing = value;
         _spriteDirty = true;
      }
      
      /**
       * <p>Set this property to create a new SpriteSheetComponent that loads
       * the specified image, and to use that as the source for rendering.</p>
       *
       * <p>You probably won't want to use this in production code, but it greatly
       * simplifies getting started.</p>
       */
      public function set loadFromImage(value:String):void
      {
         var imageAsSpriteSheet:SpriteSheetComponent = new SpriteSheetComponent();
         imageAsSpriteSheet.imageFilename = value;
         spriteSheet = imageAsSpriteSheet;
      }      
      
      /**
       * Whether or not to flip the sprite about the x axis.
       */
      public function get flipX():Boolean
      {
         return _flipX;
      }
      
      /**
       * @private
       */
      public function set flipX(value:Boolean):void
      {
         _flipX = value;
         _spriteDirty = true;
      }
      
      /**
       * Whether or not to flip the sprite about the y axis.
       */
      public function get flipY():Boolean
      {
         return _flipY;
      }
      
      /**
       * @private
       */
      public function set flipY(value:Boolean):void
      {
         _flipY = value;
         _spriteDirty = true;
      }
      
      /**
       * Modulate alpha. Zero is fully translucent, one is fully opaque.
       */
      [EditorData(defaultValue="1.0")]
      public var Fade:Number = 1.0;
      
      /**
       * @inheritDoc
       */
      public override function onDraw(manager:IDrawManager2D):void
      {
         // create the sprite data - this only does anything if necessary
         generateSprite();
         
         // if things aren't loaded yet, the sprite may still be dirty.
         if (_spriteDirty)
            return;
            
         // Skip drawing if it's so invisible as to be unnoticeable.
         if(Fade < 1.0/256.0)
           return;
              
         var position:Point = renderPosition;
         position = manager.transformWorldToScreen(position);
         
         var rotation:Number = owner.getProperty(RotationReference);
         
         var scale:Point = new Point(1,1);
         var size:Point = owner.getProperty(SizeReference);
         if (size)
         {
            scale.x = size.x / _baseSize.x;
            scale.y = size.y / _baseSize.y;
         }
         else if(rotation == 0 
               && !_flipX && !_flipY 
               && Fade == 1 && rawSprite.filters.length == 0
               && _spriteSheet && manager.getBackBuffer())
         {
            // Eligible for fast path using copy pixels.
            if (_spriteSheet)
            {
               position.x += -_spriteSheet.center.x;
               position.y += -_spriteSheet.center.y;
            }

            manager.copyPixels(getCurrentFrame(), position);
            return;
         }
         
         if (_flipX)
            scale.x = -scale.x;
         
         if (_flipY)
            scale.y = -scale.y;
         
         _sprite.alpha = Fade;         
          
         _matrix.identity();
         _matrix.scale(scale.x,scale.y);
         
         if (_spriteSheet)
            _matrix.translate(-_spriteSheet.center.x * scale.x, -_spriteSheet.center.y * scale.y);
         
         _matrix.rotate(Utility.getRadiansFromDegrees(rotation));
         _matrix.translate(position.x, position.y);
         
         _sprite.transform.matrix = _matrix;  
         
         manager.drawDisplayObject(_sprite);
      }
      
      /**
       * Given a point in worldspace, check if the sprite is opaque there.
       */
      public function pointOccupied(point:Point, scene:IDrawManager2D):Boolean
      {
         // First, get the relative positions in screenspace. Don't deal with 
         // rotation yet.
         var pointInScreenSpace:Point = scene.transformWorldToScreen(point);
         var spriteUpperLeftInScreenSpace:Point = scene.transformWorldToScreen(renderPosition);
         if (_spriteSheet)
         {
            spriteUpperLeftInScreenSpace.x += -_spriteSheet.center.x;
            spriteUpperLeftInScreenSpace.y += -_spriteSheet.center.y;
         }
         
         // Then we can get the current frame and inquire of it.
         var bd:BitmapData = getCurrentFrame();
         if(!bd)
            return false;
         
         return bd.hitTest(spriteUpperLeftInScreenSpace, 0xF0, pointInScreenSpace);
      }
      
      /**
       * @inheritDoc
       */
      protected override function onAdd():void
      {
         _spriteDirty = true;
      }
      
      /**
       * @inheritDoc
       */
      protected override function onRemove():void 
      {
         _sprite = null;
      }
      
      protected function getCurrentFrame():BitmapData
      {
         return _spriteSheet.getFrame(_spriteIndex);
      }
      
      /**
       * Update the cached sprite that we use for rendering.
       */
      protected function generateSprite():void
      {
         // Don't regenerate if we don't need it.
         if (!_spriteDirty)
            return;
         
         if (!_spriteSheet || !_spriteSheet.isLoaded)
         {
            // Draw a simple circle.
            _baseSize = new Point(25,25);
            
            if(!_sprite || !(_sprite is Sprite))
               _sprite = new Sprite();

            (_sprite as Sprite).graphics.clear();
            (_sprite as Sprite).graphics.beginFill(0xFF00FF, 0.5);
            (_sprite as Sprite).graphics.drawCircle(12.5, 12.5, 25);
            (_sprite as Sprite).graphics.endFill();
            
            if (!_spriteSheet)
               _spriteDirty = false;
         }
         else
         {
            var bmpData:BitmapData = getCurrentFrame();
            if (!bmpData)
            {
               Logger.printError(this, "generateSprite", "Failed to get a valid BitmapData back from GetCurrentFrame!");
               _sprite = null;
               return;
            }
            
            _baseSize = new Point(bmpData.width, bmpData.height);
            
            if (!_sprite || !(_sprite is Bitmap))
            {
               _sprite = new Bitmap(bmpData, "auto", _smoothing);
            }
            else
            {
               (_sprite as Bitmap).bitmapData = bmpData;
               (_sprite as Bitmap).smoothing = _smoothing;
            }
            
            _spriteDirty = false;
         }
      }
      
      protected var _spriteSheet:SpriteSheetComponent = null;
      protected var _spriteIndex:int = 0;
      protected var _sprite:DisplayObject = null;
      protected var _spriteDirty:Boolean = false;
      protected var _matrix:Matrix = new Matrix();
      protected var _smoothing:Boolean = true;
      
      protected var _baseSize:Point = null;
      protected var _flipX:Boolean = false;
      protected var _flipY:Boolean = false;
   }
}
