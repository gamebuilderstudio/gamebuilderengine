/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is property of PushButton Labs, LLC and NOT under the MIT license.
 ******************************************************************************/
package
{
    import com.pblabs.engine.core.*;
    import com.pblabs.screens.*;
    
    import flash.display.*;
    import flash.events.Event;
    
    [SWF(width="640", height="480", frameRate="60", backgroundColor="0x000000")]
    public class RollyBallGame extends Sprite
    {
        public var components:Components = new Components();
        public var resources:GameResources = new GameResources();
        
        public function RollyBallGame()
        {
            // Initialize game
            Global.startup(this);
            
            // Initialize level and score.
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
            
            stage.addEventListener(Event.DEACTIVATE, function():void{ ProcessManager.instance.timeScale = 0; });
            stage.addEventListener(Event.ACTIVATE, function():void{ ProcessManager.instance.timeScale = 1; });
            
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
            LevelManager.instance.unloadCurrentLevel();
            LevelManager.instance.loadLevel(LevelManager.instance.currentLevel);
            
            // Reset the timer and score.
            startTimer = ProcessManager.instance.virtualTime;
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
            startTimer = ProcessManager.instance.virtualTime;
            currentScore = 0;
        }
        
        public static function nextLevel():void
        {
            if(LevelManager.instance.currentLevel < 1)
            {
                LevelManager.instance.unloadCurrentLevel();
                LevelManager.instance.loadNextLevel();               
                
                // Reset the timer.
                startTimer = ProcessManager.instance.virtualTime;
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