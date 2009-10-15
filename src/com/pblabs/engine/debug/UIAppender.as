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
		 
	 	 // Try to create the flex LogViewer.
		 _logViewer = TypeUtility.instantiate("com.pblabs.engine.debug.log4PBE.LogViewer", true);
         if(!_logViewer)
		 {
			 // Fail over to ActionScript only Log Viewer
			 _logViewer = new LogViewerAS();
		 }
      }
      
      private function onKeyDown(event:KeyboardEvent):void
      {
         if (event.keyCode != InputKey.TILDE.keyCode)
            return;
		 
		 if(_logViewer)
		 {
			 if (_logViewer.parent)
				 _logViewer.parent.removeChild(_logViewer); 
			 else
				 PBE.mainClass.addChild(_logViewer);
             
             _logViewer.updateSize();
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