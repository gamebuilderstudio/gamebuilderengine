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
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.core.LevelManager;
    import com.pblabs.rendering2D.DisplayObjectScene;
    import com.pblabs.rendering2D.SpriteSheetRenderer;
    import com.pblabs.rendering2D.spritesheet.SpriteSheetComponent;
    import com.pblabs.rendering2D.SimpleSpatialComponent;
    import com.pblabs.rendering2D.BasicSpatialManager2D;
    import com.pblabs.rendering2D.spritesheet.CellCountDivider;
    import com.pblabs.rendering2D.ui.SceneView;
    import com.pblabs.box2D.Box2DDebugComponent;
    import com.pblabs.box2D.Box2DManagerComponent;
    import com.pblabs.box2D.Box2DSpatialComponent;
    import com.pblabs.box2D.PolygonCollisionShape;
    import com.pblabs.box2D.CircleCollisionShape;
    import com.pblabs.stupidSampleGame.DudeController;
    import com.pblabs.animation.AnimatorComponent;
    
    import flash.display.Sprite;
    import flash.utils.*;
    
    [SWF(width="800", height="600", frameRate="60")]
    public class PBFlexlessEngineDemo extends Sprite
    {        
        private var _resources:Resources;
        
        public function PBFlexlessEngineDemo()
        {
            // Load our resources.
            new Resources();
            
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

            // Load the descriptions, and start up level 1.
            LevelManager.instance.load("../assets/levelDescriptions.xml", 1);
        }
    }
}
