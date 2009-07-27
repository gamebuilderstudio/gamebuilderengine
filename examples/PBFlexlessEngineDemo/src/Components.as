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
   import com.pblabs.rendering2D.Scene2DComponent;
   import com.pblabs.rendering2D.SpriteRenderComponent;
   import com.pblabs.rendering2D.SpriteSheetComponent;
   import com.pblabs.rendering2D.SimpleSpatialComponent;
   import com.pblabs.rendering2D.BasicSpatialManager2D;
   import com.pblabs.rendering2D.CellCountDivider;
   import com.pblabs.Box2D.Box2DDebugComponent;
   import com.pblabs.Box2D.Box2DManagerComponent;
   import com.pblabs.Box2D.Box2DSpatialComponent;
   import com.pblabs.Box2D.PolygonCollisionShape;
   import com.pblabs.Box2D.CircleCollisionShape;
   import com.pblabs.StupidSampleGame.DudeController;
   import com.pblabs.Animation.AnimatorComponent;
   import com.pblabs.rendering2D.UI.SceneView;
   
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