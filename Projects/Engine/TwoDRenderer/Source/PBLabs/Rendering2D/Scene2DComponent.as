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
   import PBLabs.Engine.Entity.*;
   import PBLabs.Engine.Core.*;
   
   import flash.display.*;
   import flash.geom.*;
   
   import mx.core.UIComponent;
   
   /**
    * Component to manage rendering a 2d scene. It queries a ISpatialManager2D
    * to determine what is visible.
    */ 
   public class Scene2DComponent extends BaseSceneComponent
   {
      public function get CameraObject():DisplayObjectContainer
      {
         return _sprite as DisplayObjectContainer;
      }
      
      /**
       * Offset of current view.
       */
      public function get Position():Point
      {
         if (_sprite == null)
            return _position;
         
         return new Point(-_sprite.x + (_sprite.stage.stageWidth * 0.5), -_sprite.y + (_sprite.stage.stageHeight * 0.5));
      }
      
      public function set Position(value:Point):void
      {
         _position = new Point(value.x, value.y);
      }
      
      public override function OnFrame(elapsed:Number):void
      {
         super.OnFrame(elapsed);
         if(_trackObject)
            Position = new Point(_trackObject.RenderPosition.x, _trackObject.RenderPosition.y);
      }
      
      protected override function _OnRemove():void 
      {
         super._OnRemove();
         _trackObject = null;
      }

      protected override function Render():void
      {
         // Wipe all our existing renderables.
         var spriteAsDOC:DisplayObjectContainer = _sprite as DisplayObjectContainer;
         while(spriteAsDOC.numChildren)
            spriteAsDOC.removeChildAt(0);

         // Update our position.
         if(_trackObject)
         {
            _position.x = _trackObject.RenderPosition.x;
            _position.y = _trackObject.RenderPosition.y;
         }

         // Figure out what will be drawn.
         var layerList:Array = new Array(LAYER_COUNT);
         var viewRect:Rectangle = new Rectangle(_position.x - _sprite.width * 0.5, _position.y - _sprite.height * 0.5, _sprite.width, _sprite.height);
         _BuildRenderList(viewRect, layerList);
         
         // Find a trackable object if any.
         var resArray:Array = new Array();
         for each(var layer:Array in layerList)
         {
            for each(var brc:BaseRenderComponent in layer)
            {
                if(brc && brc.IsTracked)
                {
                    _trackObject = brc;
                    break;
                }
            }
         }

         // No sorting to do for the 2d view.

         // So draw the layers in order.
         _DrawSortedLayers(layerList);
      }
      
      public override function TransformWorldToScreen(p:Point, altitude:Number = 0):Point
      {
         var newP:Point = new Point();
         newP.x = (p.x - _position.x) + _sprite.width * 0.5;
         newP.y = (p.y - _position.y) + _sprite.height * 0.5;
         return newP;
      }
      
      private var _position:Point = new Point(0, 0);
      private var _trackObject:IDrawable2D = null;
   }
}