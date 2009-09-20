package com.pblabs.engine.debug.log4PBE
{
   import com.pblabs.engine.core.Global;
   import com.pblabs.engine.core.InputKey;
   import com.pblabs.engine.core.InputManager;
   import com.pblabs.engine.serialization.TypeUtility;
   
   import flash.events.KeyboardEvent;

   /**
    * LogAppender for displaying log messages in a LogViewer flex ui component. The LogViewer will be
    * attached and detached from the main view when the tilde (~) key is pressed.
    */
   public class UIAppender extends LogAppender
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
				 Global.mainStage.addChild(_logViewer);
             
             _logViewer.updateSize();
         }
      }
      
      override public function addLogMessage(level:String, loggerName:String, errorNumber:int, message:String, arguments:Array):void
      {
          // Drop all but the class name for the logger name to make it easier to read.
          var lastIdx:int = loggerName.lastIndexOf(".") + 1;
          if(lastIdx != 0)
            loggerName = loggerName.substr(lastIdx);
          
		  if(_logViewer)
         	_logViewer.addLogMessage(level, loggerName, errorNumber, replace(message, arguments), []);
      }
      
      private var _logViewer:*;
   }
}