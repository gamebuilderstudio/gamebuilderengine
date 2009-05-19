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
   import flash.events.EventDispatcher;
   
   /**
    * @eventType PBLabs.Engine.Debug.LogEvent.ENTRY_ADDED_EVENT
    */
   [Event(name="ENTRY_ADDED_EVENT", type="PBLabs.Engine.Debug.LogEvent")]
   
   /**
    * The Logger class provides mechanisms to print and listen for errors, warnings,
    * and general messages. The built in 'trace' command will output messages to the
    * console, but this allows you to differentiate between different types of
    * messages, give more detailed information about the origin of the message, and
    * listen for log events so they can be displayed in a UI component.
    * 
    * <p>To listen for new log events, subscribe to the ENTRY_ADDED_EVENT with the
    * addEventListener method. Callbacks for this event will receive a LogEvent.</p>
    * 
    * @see LogEvent
    * @see LogEntry
    */
   public class Logger extends EventDispatcher
   {
      /**
       * The singleton Logger instance.
       */
      public static function get Instance():Logger
      {
         if (_instance == null)
            _instance = new Logger();
         
         return _instance;
      }
      
      /**
       * Prints a general message to the log. Log entries created with this method
       * will have the MESSAGE type.
       * 
       * @param reporter The object that reported the message. This can be null.
       * @param message The message to print to the log.
       */
      public static function Print(reporter:*, message:String):void
      {
         var entry:LogEntry = new LogEntry();
         entry.Reporter = reporter;
         entry.Message = message;
         entry.Type = LogEntry.MESSAGE;
         Instance._AddEntry(entry);
      }
      
      /**
       * Prints a general message to the log. Log entries created with this method
       * will have the MESSAGE type. This is the same as the Print method, with the
       * exception that the Push method is automatically called to indent subsequent
       * log messages.
       * 
       * @param reporter The object that reported the message. This can be null.
       * @param message The message to print to the log.
       * 
       * @see #Push()
       */
      public static function PrintHeader(reporter:*, message:String):void
      {
         Print(reporter, message);
         Push();
      }
      
      /**
       * Prints a general message to the log. Log entries created with this method
       * will have the MESSAGE type. This is the same as the Print method, with the
       * exception that the Pop method is automatically called to decrease the message
       * indent level.
       * 
       * @param reporter The object that reported the message. This can be null.
       * @param message The message to print to the log.
       * 
       * @see #Pop()
       */
      public static function PrintFooter(reporter:*, message:String):void
      {
         Print(reporter, message);
         Pop();
      }
      
      /**
       * Prints a warning message to the log. Log entries created with this method
       * will have the WARNING type.
       * 
       * @param reporter The object that reported the warning. This can be null.
       * @param method The name of the method that the warning was reported from.
       * @param message The warning to print to the log.
       */
      public static function PrintWarning(reporter:*, method:String, message:String):void
      {
         var entry:LogEntry = new LogEntry();
         entry.Reporter = reporter;
         entry.Method = method;
         entry.Message = message;
         entry.Type = LogEntry.WARNING;
         Instance._AddEntry(entry);
      }
      
      /**
       * Prints an error message to the log. Log entries created with this method
       * will have the ERROR type.
       * 
       * @param reporter The object that reported the error. This can be null.
       * @param method The name of the method that the error was reported from.
       * @param message The error to print to the log.
       */
      public static function PrintError(reporter:*, method:String, message:String):void
      {
         var entry:LogEntry = new LogEntry();
         entry.Reporter = reporter;
         entry.Method = method;
         entry.Message = message;
         entry.Type = LogEntry.ERROR;
         Instance._AddEntry(entry);
      }
      
      /**
       * Prints a message to the log. Log enthries created with this method will have
       * the type specified in the 'type' parameter.
       * 
       * @param reporter The object that reported the message. This can be null.
       * @param method The name of the method that the error was reported from.
       * @param message The message to print to the log.
       * @param type The custom type to give the message.
       */
      public static function PrintCustom(reporter:*, method:String, message:String, type:String):void
      {
         var entry:LogEntry = new LogEntry();
         entry.Reporter = reporter;
         entry.Method = method;
         entry.Message = message;
         entry.Type = type;
         Instance._AddEntry(entry);
      }
      
      /**
       * Increases the depth of subsequent messages printed to the log. The depth can
       * be used to format the output of log entries by, for example, indenting messages
       * a number of times equal to their depth. In this way, messages that give more
       * detail about a previous message can be 'parented' to that message.
       * 
       * <p>Decrease the indent with the Pop method.</p>
       * 
       * @see #Pop()
       * @see #PrintHeader()
       */
      public static function Push():void
      {
         _instance._depth++;
      }
      
      /**
       * Decreases the depth of subsequent messages printed to the log. This is the
       * inverse of the Push method.
       * 
       * @see #Push()
       * @see #PrintFooter()
       */
      public static function Pop():void
      {
         Instance._depth--;
      }
      
      private static var _instance:Logger = new Logger();
      
      /**
       * A list of all the entries that have been printed to the log.
       */
      public function get Entries():Array
      {
         return _entries;
      }
      
      private function _AddEntry(entry:LogEntry):void
      {
         entry.Depth = _depth;
         
         var indent:String = "";
         for (var i:int = 0; i < entry.Depth; i++)
            indent += "   ";
         
         var method:String = "";
         if (entry.Type != LogEntry.MESSAGE)
            method = entry.Method + ": ";
         
         trace(indent + entry.Reporter + " - " + method + entry.Message);
         dispatchEvent(new LogEvent(LogEvent.ENTRY_ADDED_EVENT, entry));
         
         _entries.push(entry);
      }
      
      private var _depth:int = 0;
      private var _entries:Array = new Array();
   }
}