package PBLabs.Engine.Debug.Log4PBE
{
   public class ExceptionAppender extends LogAppender
   {
      public override function AddLogMessage(level:String, loggerName:String, errorNumber:int, message:String, arguments:Array):void
      {
         if (level != "FATAL")
            return;
         
         var numberString:String = "";
         if (errorNumber >= 0)
            numberString = "Error #" + errorNumber;
         
         throw new Error(numberString + _Replace(message, arguments));
      }
   }
}