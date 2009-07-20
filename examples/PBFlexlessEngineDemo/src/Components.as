/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
 
package
{
   import PBLabs.Rendering2D.Scene2DComponent;
   import PBLabs.Rendering2D.SpriteRenderComponent;
   import PBLabs.Rendering2D.SpriteSheetComponent;
   import PBLabs.Rendering2D.SimpleSpatialComponent;
   import PBLabs.Rendering2D.BasicSpatialManager2D;
   import PBLabs.Rendering2D.CellCountDivider;
   import PBLabs.Box2D.Box2DDebugComponent;
   import PBLabs.Box2D.Box2DManagerComponent;
   import PBLabs.Box2D.Box2DSpatialComponent;
   import PBLabs.Box2D.PolygonCollisionShape;
   import PBLabs.Box2D.CircleCollisionShape;
   import PBLabs.StupidSampleGame.DudeController;
   import PBLabs.Animation.AnimatorComponent;
   import PBLabs.Rendering2D.UI.SceneView;
   
   public class Components
   {
      private var _scene2DComponent:PBLabs.Rendering2D.Scene2DComponent;
      private var _spriteRenderComponent:PBLabs.Rendering2D.SpriteRenderComponent;
      private var _spriteSheetComponent:PBLabs.Rendering2D.SpriteSheetComponent;
      private var _simpleSpatialComponent:PBLabs.Rendering2D.SimpleSpatialComponent;
      private var _basicSpatialManager2D:PBLabs.Rendering2D.BasicSpatialManager2D;
      private var _cellCountDivider:PBLabs.Rendering2D.CellCountDivider;
      private var _box2DDebugComponent:PBLabs.Box2D.Box2DDebugComponent;
      private var _box2DManagerComponent:PBLabs.Box2D.Box2DManagerComponent;
      private var _box2DSpatialComponent:PBLabs.Box2D.Box2DSpatialComponent;
      private var _polygonCollisionShape:PBLabs.Box2D.PolygonCollisionShape;
      private var _circleCollisionShape:PBLabs.Box2D.CircleCollisionShape;
      private var _dudeController:PBLabs.StupidSampleGame.DudeController;
      private var _animatorComponent:PBLabs.Animation.AnimatorComponent;
      private var _sceneView:PBLabs.Rendering2D.UI.SceneView;
   }
}