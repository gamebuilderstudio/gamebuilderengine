package
{
    import com.pblabs.engine.core.*;
    import com.pblabs.rendering2D.ui.PBLabel;
    import com.pblabs.rendering2D.ui.SceneView;
    import com.pblabs.screens.*;
    import flash.geom.*;
    import flash.text.*;
    
    public class GameScreen extends BaseScreen
    {
        public var sceneView:SceneView = new SceneView();
        public var lblTime:PBLabel = new PBLabel();
        public var lblScore:PBLabel = new PBLabel();
        
        public function GameScreen()
        {
            sceneView.name = "MainView";
            sceneView.width = 640;
            sceneView.height = 480;
            addChild(sceneView);
            
            addChild(lblTime);
            lblTime.extents = new Rectangle(0, 0, 150, 30);
            lblTime.fontColor = 0xFFFF00;
            lblTime.fontSize = 24;
            lblTime.refresh();
            
            addChild(lblScore);
            lblScore.extents = new Rectangle(640 - 150, 0, 150, 30);
            lblScore.fontColor = 0xFFFF00;
            lblScore.fontSize = 24;
            lblScore.fontAlign = TextFormatAlign.RIGHT;
            lblScore.refresh();
        }
        
        public override function onShow():void
        {
        }
        
        public override function onFrame(delta:Number) : void
        {
            // Update time.
            RollyBallGame.currentTime = RollyBallGame.levelDuration - (ProcessManager.instance.virtualTime - RollyBallGame.startTimer);
            if(RollyBallGame.currentTime >= 0)
                lblTime.caption = "Time: " + (RollyBallGame.currentTime/1000).toFixed(2);
            else
                lblTime.caption = "Time: 0.00";
            lblTime.refresh();
            
            // Update score.
            lblScore.caption = "Score: " + RollyBallGame.currentScore;
            lblScore.refresh();
            
            // Deal with timing logic.
            if(RollyBallGame.currentTime <= 0 && ProcessManager.instance.isTicking)
            {
                // Stop playing!
                ProcessManager.instance.stop();
                
                // Kick off the scoreboard.
                var sb:Scoreboard = new Scoreboard();
                addChild(sb);
                sb.StartReport(RollyBallGame.currentScore);
            }
        }
        
        public override function onHide() : void
        {
        }
    }
}

