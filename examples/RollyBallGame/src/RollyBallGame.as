/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is property of PushButton Labs, LLC and NOT under the MIT license.
 ******************************************************************************/
package
{
    import com.pblabs.animation.*;
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.core.*;
    import com.pblabs.engine.resource.ResourceManager;
    import com.pblabs.rendering2D.*;
    import com.pblabs.rendering2D.spritesheet.*;
    import com.pblabs.rendering2D.ui.*;
    import com.pblabs.rollyGame.*;
    import com.pblabs.screens.*;
    
    import flash.display.*;
    import flash.events.Event;
    
    [SWF(width="640", height="480", frameRate="60", backgroundColor="0x000000")]
    public class RollyBallGame extends Sprite
    {
        // Instantiating GameResources loads all our embedded resources.
        public var resources:GameResources = new GameResources();
        
        public function RollyBallGame()
        {
            // Enable this to ensure all resources are embedded.
            //ResourceManager.instance.onEmbeddedFail = trace;
            //ResourceManager.instance.onlyLoadEmbeddedResources = true;
            
            // Register our types.
            PBE.registerType(com.pblabs.rendering2D.DisplayObjectScene);
            PBE.registerType(com.pblabs.rendering2D.SpriteSheetRenderer);
            PBE.registerType(com.pblabs.rendering2D.SimpleSpatialComponent);
            PBE.registerType(com.pblabs.rendering2D.BasicSpatialManager2D);
            PBE.registerType(com.pblabs.rendering2D.spritesheet.CellCountDivider);
            PBE.registerType(com.pblabs.rendering2D.spritesheet.SpriteSheetComponent);
            PBE.registerType(com.pblabs.rendering2D.ui.SceneView);
            PBE.registerType(com.pblabs.animation.AnimatorComponent);
            PBE.registerType(com.pblabs.rollyGame.NormalMap);
            PBE.registerType(com.pblabs.rollyGame.BallMover);
            PBE.registerType(com.pblabs.rollyGame.BallShadowRenderer);
            PBE.registerType(com.pblabs.rollyGame.BallSpriteRenderer);            
            
            // Initialize game.
            PBE.startup(this);
            
            // Initialize level.
            LevelManager.instance.addFileReference(0, "../assets/Levels/level.pbelevel");
            LevelManager.instance.addGroupReference(0, "Everything");
            
            LevelManager.instance.addFileReference(1, "../assets/Levels/level.pbelevel");
            LevelManager.instance.addGroupReference(1, "Everything");
            LevelManager.instance.addGroupReference(1, "Level1");
            
            LevelManager.instance.addFileReference(2, "../assets/Levels/level.pbelevel");
            LevelManager.instance.addGroupReference(2, "Everything");
            LevelManager.instance.addGroupReference(2, "Level2");
            
            // Make the game scale properly.
            stage.scaleMode = StageScaleMode.SHOW_ALL; 
            
            // Pause/resume based on focus.
            stage.addEventListener(Event.DEACTIVATE, function():void{ PBE.processManager.timeScale = 0; });
            stage.addEventListener(Event.ACTIVATE, function():void{ PBE.processManager.timeScale = 1; });
            
            // Set up our screens.
            ScreenManager.instance.registerScreen("splash", new SplashScreen("../assets/Images/level1_normal.png", "game"));
            ScreenManager.instance.registerScreen("game", new GameScreen());
            ScreenManager.instance.registerScreen("gameOver", new GameOverScreen());
            ScreenManager.instance.goto("splash");
            
            LevelManager.instance.start(1);
        }

        // Global game state.
        public static var currentScore:int = 0;
        public static var startTimer:Number = 0;
        public static var currentTime:Number = 60.0;
        public static var levelDuration:Number = 45000;
        
        public static function resetLevel():void
        {
            // Reset the level.
            var curLevel:int = LevelManager.instance.currentLevel;
            LevelManager.instance.unloadCurrentLevel();
            LevelManager.instance.loadLevel(curLevel);
            
            // Reset the timer and score.
            startTimer = PBE.processManager.virtualTime;
            currentScore = 0;
            levelDuration = 45000;
            currentTime = 60.0;
        }
        
        public static function restartGame():void
        {
            // Reset the level.
            LevelManager.instance.unloadCurrentLevel();
            LevelManager.instance.loadLevel(1);
            
            // Reset the timer and score.
            startTimer = PBE.processManager.virtualTime;
            currentScore = 0;
        }
        
        public static function nextLevel():void
        {
            if(LevelManager.instance.currentLevel < 2)
            {
                LevelManager.instance.loadNextLevel();               
                
                // Reset the timer.
                startTimer = PBE.processManager.virtualTime;
                currentScore = 0;
                
                ScreenManager.instance.goto("game");
            }
            else
            {
                ScreenManager.instance.goto("gameOver");
            }
        }
        
        
    }    
}