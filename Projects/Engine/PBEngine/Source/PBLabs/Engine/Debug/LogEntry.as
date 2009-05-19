/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Engine.Debug
{
   /**
    * Log entries are automatically created by the various methods on the Logger
    * class to store information related to an entry in the log. They are also
    * dispatched in the LogEvent when the entry is added to the log to pass
    * information about the entry to the listener.
    * 
    * @see Logger
    */
   public class LogEntry
   {
      /**
       * Entry type given to errors.
       * 
       * @see Logger#PrintError()
       */
      public static const ERROR:String = "ERROR";
      
      /**
       * Entry type given to warnings.
       * 
       * @see Logger#PrintWarning()
       */
      public static const WARNING:String = "WARNING";
      
      /**
       * Entry type given to generic messages.
       * 
       * @see Logger#Print()
       */
      public static const MESSAGE:String = "MESSAGE";
      
      /**
       * The object that printed the message to the log.
       */
      public var Reporter:* = null;
      
      /**
       * The method the entry was printed from.
       */
      public var Method:String = "";
      
      /**
       * The message that was printed.
       */
      public var Message:String = "";
      
      /**
       * The full message, formatted to include the reporter and method if they exist.
       */
      public function get FormattedMessage():String
      {
         var depth:String = "";
         for (var i:int = 0; i < Depth; i++)
            depth += "   ";
         
         var reporter:String = "";
         if (Reporter != null)
            reporter = Reporter + ": ";
         
         var method:String = "";
         if ((Method != null) && (Method != ""))
            method = Method + " - ";
         
         return depth + reporter + method + Message;
      }
      
      /**
       * The type of the message (message, warning, or error).
       * 
       * @see #ERROR
       * @see #WARNING
       * @see #MESSAGE
       */
      public var Type:String = null;
      
      /**
       * The depth of the message.
       * 
       * @see Logger#Push()
       */
      public var Depth:int = 0;
   }
}