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
         InputManager.Instance.addEventListener(KeyboardEvent.KEY_DOWN, _OnKeyDown);
      }
      
      private function _OnKeyDown(event:KeyboardEvent):void
      {
         if (event.keyCode != InputKey.TILDE.KeyCode)
            return;
         
         if (_logViewer.parent)
            _logViewer.parent.removeChild(_logViewer);
         else
            Global.MainClass.addChild(_logViewer);
      }
      
      public override function AddLogMessage(level:String, loggerName:String, errorNumber:int, message:String, arguments:Array):void
      {
         _logViewer.AddLogMessage(level, loggerName, errorNumber, _Replace(message, arguments));
      }
      
      private var _logViewer:LogViewer = new LogViewer();
   }
}