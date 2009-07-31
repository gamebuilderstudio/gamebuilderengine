package com.pblabs.engine.debug.log4PBE
{
   import com.pblabs.engine.core.*;
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
		 
		 // Try to create the LogViewer.
		 _logViewer = TypeUtility.instantiate("com.pblabs.engine.debug.log4PBE.LogViewer", true);
         if(!_logViewer)
             Logger.getLogger(UIAppender).warn("Could not create com.pblabs.engine.debug.log4PBE.LogViewer; if you are in an ActionScript project this is normal. No fancy UI for viewing the log output will be present.");             
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
				 Global.mainClass.addChild(_logViewer);
		 }
      }
      
      override public function addLogMessage(level:String, loggerName:String, errorNumber:int, message:String, arguments:Array):void
      {
		  if(_logViewer)
         	_logViewer.addLogMessage(level, loggerName, errorNumber, replace(message, arguments));
      }
      
      private var _logViewer:*;
   }
}