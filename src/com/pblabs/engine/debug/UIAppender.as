package com.pblabs.engine.debug
{
   import com.pblabs.engine.PBE;
   import com.pblabs.engine.core.InputKey;
   import com.pblabs.engine.core.InputManager;
   import com.pblabs.engine.serialization.TypeUtility;
   
   import flash.events.KeyboardEvent;

   /**
    * LogAppender for displaying log messages in a LogViewer flex ui component. The LogViewer will be
    * attached and detached from the main view when the tilde (~) key is pressed.
    */
   public class UIAppender implements ILogAppender
   {
      public function UIAppender()
      {
         InputManager.instance.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		 
		 // todo NB - Get rid of LogViewer.mxml and rename LogViewerAS to LogViewer
		 _logViewer = new LogViewerAS();
      }
      
      private function onKeyDown(event:KeyboardEvent):void
      {
         if (event.keyCode != InputKey.TILDE.keyCode)
            return;
		 
		 if(_logViewer)
		 {
			 if (_logViewer.parent)
			 {
				 _logViewer.parent.removeChild(_logViewer);
				 _logViewer.deactivate();
			 }
			 else
			 {
				 PBE.mainStage.addChild(_logViewer);
				 _logViewer.activate();
			 }
			 
         }
      }
      
      public function addLogMessage(level:String, loggerName:String, message:String):void
      {
		  if(_logViewer)
         	_logViewer.addLogMessage(level, loggerName, message);
      }
      
      private var _logViewer:*;
   }
}