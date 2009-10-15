package com.pblabs.engine.debug
{
   public class ExceptionAppender implements ILogAppender
   {
	   public function addLogMessage(level:String, loggerName:String, message:String):void
	   {
		   if (level != "FATAL")
			   return;
		   
		   throw new Error(message);
	   }
	   
     /* public function addLogMessage(level:String, loggerName:String, message:String, arguments:Array):void
      {
         if (level != "FATAL")
            return;
         
         var numberString:String = "";
         if (errorNumber >= 0)
            numberString = "Error #" + errorNumber;
         
         throw new Error(numberString + replace(message, arguments));
      }*/
   }
}