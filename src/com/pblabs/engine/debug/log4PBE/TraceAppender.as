package com.pblabs.engine.debug.log4PBE
{
   public class TraceAppender extends LogAppender
   {
      public override function addLogMessage(level:String, loggerName:String, errorNumber:int, message:String, arguments:Array):void
      {
         var numberString:String = "";
         if (errorNumber >= 0)
            numberString = " - " + errorNumber;
         
         trace(level + ": " + loggerName + numberString + " - " + _Replace(message, arguments));
      }
   }
}