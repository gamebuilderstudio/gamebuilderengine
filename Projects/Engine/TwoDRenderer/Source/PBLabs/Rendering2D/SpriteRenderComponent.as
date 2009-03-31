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
   import PBLabs.Engine.Entity.PropertyReference;
   import PBLabs.Engine.Core.ProcessManager;
   
   import flash.display.BitmapData;
   import flash.display.Sprite;
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
      public function get SpriteSheet():SpriteSheetComponent
      {
         return _spriteSheet;
      }
      
      /**
       * @private
       */
      public function set SpriteSheet(value:SpriteSheetComponent):void
      {
         _spriteSheet = value;
         _spriteDirty = true;
      }
      
      /**
       * The index in the sprite sheet of the frame to draw.
       */
      public function get SpriteIndex():int
      {
         return _spriteIndex;
      }
      
      /**
       * @private
       */
      public function set SpriteIndex(value:int):void
      {
         _spriteIndex = value;
         _spriteDirty = true;
      }
      
      /**
       * Whether or not to flip the sprite about the x axis.
       */
      public function get FlipX():Boolean
      {
         return _flipX;
      }
      
      /**
       * @private
       */
      public function set FlipX(value:Boolean):void
      {
         _flipX = value;
         _spriteDirty = true;
      }
      
      /**
       * Whether or not to flip the sprite about the y axis.
       */
      public function get FlipY():Boolean
      {
         return _flipY;
      }
      
      /**
       * @private
       */
      public function set FlipY(value:Boolean):void
      {
         _flipY = value;
         _spriteDirty = true;
      }
      
      /**
       * @inheritDoc
       */
      public override function OnDraw(manager:IDrawManager2D):void
      {
         // create the sprite data - this only does anything if necessary
         _GenerateSprite();
         
         // if things aren't loaded yet, the sprite may still be dirty.
         if (_spriteDirty)
            return;
         
         var position:Point = RenderPosition;
         position = manager.TransformWorldToScreen(position);
         _sprite.x = position.x;
         _sprite.y = position.y;
         
         var rotation:Number = Owner.GetProperty(RotationReference);
         _sprite.rotation = rotation;
         
         var size:Point = Owner.GetProperty(SizeReference);
         if (size)
         {
            _sprite.scaleX = size.x / _baseSize.x;
            _sprite.scaleY = size.y / _baseSize.y;
         }
         
         if (_flipX)
            _sprite.scaleX = -_sprite.scaleX;
         
         if (_flipY)
            _sprite.scaleY = -_sprite.scaleY;
            
         manager.DrawDisplayObject(_sprite);         
      }
      
      /**
       * @inheritDoc
       */
      protected override function _OnAdd():void
      {
         _sprite = new Sprite();
         _spriteDirty = true;
      }
      
      /**
       * @inheritDoc
       */
      protected override function _OnRemove():void 
      {
         _sprite = null;
      }
      
      private function _GenerateSprite():void
      {
         if (!_spriteDirty)
            return;
         
         if (_spriteSheet == null)
         {
            // Draw a simple circle.
            _baseSize = new Point(25,25);
            _sprite.graphics.clear();
            _sprite.graphics.beginFill(0xFF00FF, 0.5);
            _sprite.graphics.drawCircle(0, 0, 25);
            _sprite.graphics.endFill();
            
            _spriteDirty = false;
            return;
         }
         
         if (_sprite == null)
            return;
         
         if (!_spriteSheet.IsLoaded)
            return;
         
         var bitmap:BitmapData = _spriteSheet.GetFrame(_spriteIndex);
         _baseSize = new Point(bitmap.width, bitmap.height);

         var matrix:Matrix = new Matrix();
         matrix.translate(_baseSize.x * 0.5, _baseSize.y * 0.5);
         
         _sprite.graphics.clear();
         _sprite.graphics.beginBitmapFill(bitmap, matrix);
         _sprite.graphics.drawRect(-bitmap.width * 0.5, -bitmap.height * 0.5, bitmap.width, bitmap.height);
         _sprite.graphics.endFill();
         
         _spriteDirty = false;
      }
      
      private var _spriteSheet:SpriteSheetComponent = null;
      private var _spriteIndex:int = 0;
      private var _sprite:Sprite = null;
      private var _spriteDirty:Boolean = false;
      
      private var _baseSize:Point = null;
      private var _flipX:Boolean = false;
      private var _flipY:Boolean = false;
   }
}