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
    import com.pblabs.engine.debug.Logger;
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
        public function RollyBallGame()
        {
            // Enable this to ensure all resources are embedded.
            //PBE.resourceManager.onEmbeddedFail = trace;
            //PBE.resourceManager.onlyLoadEmbeddedResources = true;
            
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
            
            PBE.addResources(new GameResources());
            
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
            ScreenManager.instance.registerScreen("splash", new SplashScreen("../assets/Images/intro.png", "game"));
            ScreenManager.instance.registerScreen("game", new GameScreen());
            ScreenManager.instance.registerScreen("gameOver", new GameOverScreen());
            ScreenManager.instance.goto("splash");
        }
        
        // Global game state.
        public static var currentScore:int = 0;
        public static var startTimer:Number = 0;
        
        public static var levelDuration:Number = 45000;
        public static var currentTime:Number = levelDuration;
        
        public static function resetTimerAndScore():void
        {
            startTimer = PBE.processManager.virtualTime;
            currentScore = 0;
            currentTime = 0.0;            
        }
        
        public static function resetLevel():void
        {
            // Reset the level.
            var curLevel:int = LevelManager.instance.currentLevel;
            
            // Reset the coins.
            var cs:PBSet = PBE.lookup("CoinSet") as PBSet;
            if(cs)
                cs.clear();
            
            // Hack to properly reset level data - level 0 is always loaded
            // and has special logic in the manager, so we have to do this 
            // hack for now -- BJG
            LevelManager.instance.loadLevel(curLevel == 1 ? 2 : 1);
            LevelManager.instance.loadLevel(curLevel);
            
            // Reset the timer and score.
            resetTimerAndScore();
        }
        
        public static function restartGame():void
        {
            // Reset the coins.
            var cs:PBSet = PBE.lookup("CoinSet") as PBSet;
            if(cs)
                cs.clear();

            // Reset the level.
            LevelManager.instance.loadLevel(1);

            // Reset the timer and score.
            resetTimerAndScore();
        }
        
        public static function nextLevel():void
        {
            // Reset the coins.
            var cs:PBSet = PBE.lookup("CoinSet") as PBSet;
            if(cs)
                cs.clear();

            // Advance level as appropriate.
            if(LevelManager.instance.currentLevel < 2)
            {
                LevelManager.instance.loadNextLevel();               
                
                // Reset the timer.
                resetTimerAndScore();
                
                ScreenManager.instance.goto("game");
            }
            else
            {
                ScreenManager.instance.goto("gameOver");
            }
        }
    }    
}