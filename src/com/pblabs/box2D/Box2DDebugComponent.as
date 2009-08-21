/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.box2D
{
   import Box2D.Dynamics.b2DebugDraw;
   
   import com.pblabs.rendering2D.BaseRenderComponent;
   import com.pblabs.rendering2D.BaseSceneComponent;
   import com.pblabs.rendering2D.IDrawManager2D;
   
   import flash.display.Sprite;
   import flash.geom.Point;

   public class Box2DDebugComponent extends BaseRenderComponent
   {
      public var manager:Box2DManagerComponent;
    
      override public function get layerIndex():int
      {
         // Always draw last.
         return BaseSceneComponent.LAYER_COUNT - 1;
      }
      
      [EditorData(referenceType="componentReference")]
      public function get scene():IDrawManager2D
      {
         return _scene;
      }
      
      public function set scene(value:IDrawManager2D):void
      {
         _scene = value;
      }
      
      override protected function onAdd():void
      {
         _drawer.m_sprite = _sprite;
         _drawer.m_fillAlpha = 0.3;
         _drawer.m_lineThickness = 1.0;
         _drawer.m_drawFlags = b2DebugDraw.e_shapeBit|b2DebugDraw.e_jointBit;
         
         _scene.addAlwaysDrawnItem(this);
      }
      
      override protected function onRemove():void
      {
         _scene.removeAlwaysDrawnItem(this);
         _scene = null;
      }
      
      override protected function onReset():void 
      {
         if (manager)
            manager.setDebugDrawer(_drawer);
      }

      override public function onDraw(manager:IDrawManager2D):void
      {
         var offset:Point = manager.transformWorldToScreen(new Point());
         _sprite.x = offset.x;
         _sprite.y = offset.y;
         manager.drawDisplayObject(_sprite);
      }
      
      private var _scene:IDrawManager2D = null;
      private var _sprite:Sprite = new Sprite();
      private var _drawer:b2DebugDraw = new b2DebugDraw();
   }
}