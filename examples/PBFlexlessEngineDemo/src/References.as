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
   import com.pblabs.rendering2D.DisplayObjectScene;
   import com.pblabs.rendering2D.SpriteSheetRenderer;
   import com.pblabs.rendering2D.spritesheet.SpriteSheetComponent;
   import com.pblabs.rendering2D.SimpleSpatialComponent;
   import com.pblabs.rendering2D.BasicSpatialManager2D;
   import com.pblabs.rendering2D.spritesheet.CellCountDivider;
   import com.pblabs.box2D.Box2DDebugComponent;
   import com.pblabs.box2D.Box2DManagerComponent;
   import com.pblabs.box2D.Box2DSpatialComponent;
   import com.pblabs.box2D.PolygonCollisionShape;
   import com.pblabs.box2D.CircleCollisionShape;
   import com.pblabs.stupidSampleGame.DudeController;
   import com.pblabs.animation.AnimatorComponent;
   import com.pblabs.rendering2D.ui.SceneView;
   
   public class References
   {
      private var _scene2DComponent:com.pblabs.rendering2D.DisplayObjectScene;
      private var _spriteRenderComponent:com.pblabs.rendering2D.SpriteSheetRenderer;
      private var _simpleSpatialComponent:com.pblabs.rendering2D.SimpleSpatialComponent;
      private var _basicSpatialManager2D:com.pblabs.rendering2D.BasicSpatialManager2D;
      private var _cellCountDivider:com.pblabs.rendering2D.spritesheet.CellCountDivider;
      private var _spriteSheetComponent:com.pblabs.rendering2D.spritesheet.SpriteSheetComponent;
      private var _box2DDebugComponent:com.pblabs.box2D.Box2DDebugComponent;
      private var _box2DManagerComponent:com.pblabs.box2D.Box2DManagerComponent;
      private var _box2DSpatialComponent:com.pblabs.box2D.Box2DSpatialComponent;
      private var _polygonCollisionShape:com.pblabs.box2D.PolygonCollisionShape;
      private var _circleCollisionShape:com.pblabs.box2D.CircleCollisionShape;
      private var _dudeController:com.pblabs.stupidSampleGame.DudeController;
      private var _animatorComponent:com.pblabs.animation.AnimatorComponent;
      private var _sceneView:com.pblabs.rendering2D.ui.SceneView;
   }
}