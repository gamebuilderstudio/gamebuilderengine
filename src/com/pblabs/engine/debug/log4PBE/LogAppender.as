package com.pblabs.engine.debug.log4PBE
{
   /**
    * The LogAppender class is the base class for all appenders in the log system. An appender's
    * purpose is to output the log messages in some way so as to be useful. This can be anything
    * from sending it to the console, printing it on the screen, or sending it across a network
    * connection.
    */
   public class LogAppender
   {
      private static var _logger:Logger = Logger.getLogger(LogAppender);
      
      /**
       * Called by the LogManager to add a message to this appender. If this is called, the
       * message has passed all of the filter criteria.
       * 
       * @param level The LogLevel of the message.
       * @param loggerName The name of the logger this message came from.
       * @param errorNumber The error number, or -1 if there isn't one.
       * @param message The message text.
       * @param arguments A list of values to insert into the message text. Use the _Replace method.
       */
      public function addLogMessage(level:String, loggerName:String, errorNumber:int, message:String, arguments:Array):void
      {
         _logger.error("The LogAppender.addLogMessage method doesn't do anything. Subclasses should implement it to make it useful.");
      }
      
      /**
       * Replaces %# with values from the arguments array. For example, %1 would be replaced
       * with the first value in the array, %2 the second, etc.
       * 
       * @param message The string to make replacements on.
       * @param arguments The list of values to use as replacements.
       * 
       * @param The input string with replacements made.
       */
      protected function _Replace(message:String, arguments:Array):String
      {
         var newMessage:String = message;
         for (var i:int = 0; i < arguments.length; i++)
         {
            var pattern:String = "%" + (i + 1);
            newMessage = newMessage.replace(new RegExp(pattern, "g"), arguments[i]);
         }
         
         return newMessage;
      }
   }
}