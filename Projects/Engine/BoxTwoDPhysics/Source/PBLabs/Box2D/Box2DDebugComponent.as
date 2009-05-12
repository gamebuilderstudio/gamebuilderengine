/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Box2D
{
   import Box2D.Dynamics.b2DebugDraw;
   import PBLabs.Rendering2D.*;
   import flash.geom.Point;
   import flash.display.Sprite;

   public class Box2DDebugComponent extends BaseRenderComponent
   {
      public var Manager:Box2DManagerComponent;
    
      public override function get LayerIndex():int
      {
         // Always draw last.
         return BaseSceneComponent.LAYER_COUNT - 1;
      }
      
      [EditorData(referenceType="reference")]
      public function get Scene():IDrawManager2D
      {
         return _scene;
      }
      
      public function set Scene(value:IDrawManager2D):void
      {
         _scene = value;
      }
      
      protected override function _OnAdd():void
      {
         _drawer.m_sprite = _sprite;
         _drawer.m_fillAlpha = 0.3;
         _drawer.m_lineThickness = 1.0;
         _drawer.m_drawFlags = b2DebugDraw.e_shapeBit;
         
         _scene.AddAlwaysDrawnItem(this);
      }
      
      protected override function _OnRemove():void
      {
         _scene.RemoveAlwaysDrawnItem(this);
         _scene = null;
      }
      
      protected override function _OnReset():void 
      {
         if (Manager!= null)
            Manager.SetDebugDrawer(_drawer);
      }

      public override function OnDraw(manager:IDrawManager2D):void
      {
         var offset:Point = manager.TransformWorldToScreen(new Point());
         _sprite.x = offset.x;
         _sprite.y = offset.y;
         manager.DrawDisplayObject(_sprite);
      }
      
      private var _scene:IDrawManager2D = null;
      private var _sprite:Sprite = new Sprite();
      private var _drawer:b2DebugDraw = new b2DebugDraw();
   }
}