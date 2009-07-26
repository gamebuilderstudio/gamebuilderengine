package com.pblabs.engine.debug.log4PBE
{
   import flash.events.KeyboardEvent;
   
   import com.pblabs.engine.core.*;
   
   /**
    * LogAppender for displaying log messages in a LogViewer flex ui component. The LogViewer will be
    * attached and detached from the main view when the tilde (~) key is pressed.
    */
   public class UIAppender extends LogAppender
   {
      public function UIAppender()
      {
         InputManager.instance.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
      }
      
      private function onKeyDown(event:KeyboardEvent):void
      {
         if (event.keyCode != InputKey.TILDE.keyCode)
            return;
         
         if (_logViewer.parent)
            _logViewer.parent.removeChild(_logViewer);
         else
            Global.mainClass.addChild(_logViewer);
      }
      
      override public function addLogMessage(level:String, loggerName:String, errorNumber:int, message:String, arguments:Array):void
      {
         _logViewer.addLogMessage(level, loggerName, errorNumber, replace(message, arguments));
      }
      
      private var _logViewer:LogViewer = new LogViewer();
   }
}