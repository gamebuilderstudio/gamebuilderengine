package
{
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.core.*;
    import com.pblabs.rendering2D.ui.PBLabel;
    import com.pblabs.rendering2D.ui.SceneView;
    import com.pblabs.screens.*;
    import flash.geom.*;
    import flash.text.*;
    
    /**
     * The main screen that implements core game logic and UI.
     * 
     */
    public class GameScreen extends BaseScreen
    {
        public var sceneView:SceneView = new SceneView();
        public var lblTime:PBLabel = new PBLabel();
        public var lblScore:PBLabel = new PBLabel();
        
        public function GameScreen()
        {
            // Set up the scene view to be full screen.
            sceneView.name = "MainView";
            sceneView.width = 640;
            sceneView.height = 480;
            addChild(sceneView);
            
            // Label to display the time remaining.
            addChild(lblTime);
            lblTime.extents = new Rectangle(0, 0, 150, 30);
            lblTime.fontColor = 0xFFFF00;
            lblTime.fontSize = 24;
            lblTime.refresh();
            
            // Score indicator (also a label).
            addChild(lblScore);
            lblScore.extents = new Rectangle(640 - 150, 0, 150, 30);
            lblScore.fontColor = 0xFFFF00;
            lblScore.fontSize = 24;
            lblScore.fontAlign = TextFormatAlign.RIGHT;
            lblScore.refresh();
        }
        
        public override function onShow() : void
        {
            LevelManager.instance.start(1);
        }
        
        /**
         * Called every frame; used to update time remaining and score. Only display
         * aspects of the game are updated here. You will notice that currentTime
         * is updated; that is so it is always super-smooth, but the gameplay
         * logic happens in onTick.
         */
        public override function onFrame(delta:Number) : void
        {
            RollyBallGame.currentTime = RollyBallGame.levelDuration - (PBE.processManager.virtualTime - RollyBallGame.startTimer);

            // Update time.
            if(RollyBallGame.currentTime >= 0)
                lblTime.caption = "Time: " + (RollyBallGame.currentTime/1000).toFixed(2);
            else
                lblTime.caption = "Time: 0.00";
            lblTime.refresh();
            
            // Update score.
            lblScore.caption = "Score: " + RollyBallGame.currentScore;
            lblScore.refresh();
        }
        
        /**
         * Gameplay logic happens here; in this game, the only thing is to check
         * if the user is out of time.
         */
        public override function onTick(delta:Number) : void
        {
            // Deal with timing logic.
            if(RollyBallGame.currentTime <= 0 && PBE.processManager.isTicking)
            {
                // Stop playing!
                PBE.processManager.stop();
                
                // Kick off the scoreboard.
                var sb:Scoreboard = new Scoreboard();
                addChild(sb);
                sb.StartReport(RollyBallGame.currentScore);
            }
        }
    }
}

