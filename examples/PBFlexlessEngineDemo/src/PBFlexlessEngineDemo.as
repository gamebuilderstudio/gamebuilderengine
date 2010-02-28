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
    import com.pblabs.animation.AnimatorComponent;
    import com.pblabs.box2D.Box2DDebugComponent;
    import com.pblabs.box2D.Box2DManagerComponent;
    import com.pblabs.box2D.Box2DSpatialComponent;
    import com.pblabs.box2D.CircleCollisionShape;
    import com.pblabs.box2D.PolygonCollisionShape;
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.core.LevelManager;
    import com.pblabs.engine.resource.Resource;
    import com.pblabs.rendering2D.BasicSpatialManager2D;
    import com.pblabs.rendering2D.DisplayObjectScene;
    import com.pblabs.rendering2D.SimpleSpatialComponent;
    import com.pblabs.rendering2D.SpriteSheetRenderer;
    import com.pblabs.rendering2D.spritesheet.CellCountDivider;
    import com.pblabs.rendering2D.spritesheet.SpriteSheetComponent;
    import com.pblabs.rendering2D.ui.SceneView;
    import com.pblabs.stupidSampleGame.DudeController;
    
    import flash.display.Sprite;
    import flash.utils.*;
    
    [SWF(width="800", height="600", frameRate="60")]
    public class PBFlexlessEngineDemo extends Sprite
    {        
        public function PBFlexlessEngineDemo()
        {            
            // Make sure all the types our XML will use are registered.
            PBE.registerType(com.pblabs.rendering2D.DisplayObjectScene);
            PBE.registerType(com.pblabs.rendering2D.SpriteSheetRenderer);
            PBE.registerType(com.pblabs.rendering2D.spritesheet.SpriteSheetComponent);
            PBE.registerType(com.pblabs.rendering2D.SimpleSpatialComponent);
            PBE.registerType(com.pblabs.rendering2D.BasicSpatialManager2D);
            PBE.registerType(com.pblabs.rendering2D.spritesheet.CellCountDivider);
            PBE.registerType(com.pblabs.rendering2D.ui.SceneView);
            PBE.registerType(com.pblabs.box2D.Box2DDebugComponent);
            PBE.registerType(com.pblabs.box2D.Box2DManagerComponent);
            PBE.registerType(com.pblabs.box2D.Box2DSpatialComponent);
            PBE.registerType(com.pblabs.box2D.PolygonCollisionShape);
            PBE.registerType(com.pblabs.box2D.CircleCollisionShape);
            PBE.registerType(com.pblabs.stupidSampleGame.DudeController);
            PBE.registerType(com.pblabs.animation.AnimatorComponent);
        
            // Initialize the engine!
            PBE.startup(this);
            
            // Load resources.
            PBE.addResources(new Resources());

            // Set up the scene view.
            var sv:SceneView = new SceneView();
            sv.name = "MainView";
            sv.x = 0;
            sv.y = 0;
            sv.width = 800;
            sv.height = 600;
            addChild(sv);

            // Load the descriptions, and start up level 1.
            LevelManager.instance.load("../assets/levelDescriptions.xml", 1);
        }
    }
}
