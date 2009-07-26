package com.pblabs.engine.debug.log4PBE
{
   /**
    * The main class for all log related activities. A Logger instance is generally
    * created for each class as a static member and used to output log messages. The
    * Logger can be created
    * 
    * @see LogManager
    */
   public class Logger
   {
      /**
       * Retrieves a logger for the specified class. If classType is a string, that
       * string is used as the class name, regardless of what it is. For any other
       * object, the class type of that object is used. Most commonly, a Class object
       * is passed in.
       * 
       * <p>Although this shouldn't happen, if this is called multiple times for the
       * same classType, the same logger will be returned rather than creating a new
       * one.
       * </p>
       */
      public static function GetLogger(classType:*):Logger
      {
         // grab from the logger so it can return a cached version if necessary
         return LogManager.Instance.GetLogger(classType);
      }
      
      internal static function Create(name:String):Logger
      {
         // this exists so the LogManager can create Loggers, but nothing outside can
         return new Logger(name, new LoggerKey());
      }
      
      /**
       * Creates a Logger. Use the static GetLogger method to create a Logger rather than
       * using this directly.
       */
      public function Logger(name:String, key:LoggerKey)
      {
         // uncomment this when we move to flex style - right now there's a conflict with the error method
         //if (!key)
         //   throw new Error("Loggers cannot be created manually! Use the static GetLogger method instead.");
         
         _name = name;
      }
      
      /**
       * The name of the Logger.
       */
      public function get Name():String
      {
         return _name;
      }
      
      /**
       * Checks if this logger is enabled at the specified log level.
       * 
       * @param level The level to check against.
       * 
       * @return True if the logger is enabled, false otherwise.
       */
      public function IsEnabledFor(level:String):Boolean
      {
         return LogManager.Instance.IsLoggerEnabledFor(this, level);
      }
      
      /**
       * Outputs a log message at the "trace" level.
       * 
       * @param message The message to print. This can include %# markers as replacement locations
       * for subsequent arguments. For instance, '%1' would be replaced by the first additional
       * parameter passed to the method, and '%4' would be replaced by the fourth.
       */
      public function Trace(message:String, ...arguments:Array):void
      {
         LogManager.Instance.AddLogMessage("trace", this, message, arguments);
      }
      
      /**
       * Outputs a log message at the "debug" level.
       * 
       * @param message The message to print. This can include %# markers as replacement locations
       * for subsequent arguments. For instance, '%1' would be replaced by the first additional
       * parameter passed to the method, and '%4' would be replaced by the fourth.
       */
      public function Debug(message:String, ...arguments:Array):void
      {
         LogManager.Instance.AddLogMessage("debug", this, message, arguments);
      }
      
      /**
       * Outputs a log message at the "info" level.
       * 
       * @param message The message to print. This can include %# markers as replacement locations
       * for subsequent arguments. For instance, '%1' would be replaced by the first additional
       * parameter passed to the method, and '%4' would be replaced by the fourth.
       */
      public function Info(message:String, ...arguments:Array):void
      {
         LogManager.Instance.AddLogMessage("info", this, message, arguments);
      }
      
      /**
       * Outputs a log message at the "warn" level.
       * 
       * @param message The message to print. This can include %# markers as replacement locations
       * for subsequent arguments. For instance, '%1' would be replaced by the first additional
       * parameter passed to the method, and '%4' would be replaced by the fourth.
       */
      public function Warn(message:String, ...arguments:Array):void
      {
         LogManager.Instance.AddLogMessage("warn", this, message, arguments);
      }
      
      /**
       * Outputs a log message at the "error" level.
       * 
       * @param message The message to print. This can include %# markers as replacement locations
       * for subsequent arguments. For instance, '%1' would be replaced by the first additional
       * parameter passed to the method, and '%4' would be replaced by the fourth.
       */
      public function Error(message:String, ...arguments:Array):void
      {
         LogManager.Instance.AddLogMessage("error", this, message, arguments);
      }
      
      /**
       * Outputs a log message at the "fatal" level.
       * 
       * @param message The message to print. This can include %# markers as replacement locations
       * for subsequent arguments. For instance, '%1' would be replaced by the first additional
       * parameter passed to the method, and '%4' would be replaced by the fourth.
       */
      public function Fatal(message:String, ...arguments:Array):void
      {
         LogManager.Instance.AddLogMessage("fatal", this, message, arguments);
      }
      
      /**
       * Outputs a log message at the specified level.
       * 
       * @param level The level to output the message at.
       * @param message The message to print. This can include %# markers as replacement locations
       * for subsequent arguments. For instance, '%1' would be replaced by the first additional
       * parameter passed to the method, and '%4' would be replaced by the fourth.
       */
      public function Log(level:String, message:String, ...arguments:Array):void
      {
         LogManager.Instance.AddLogMessage(level, this, message, arguments);
      }
      
      private var _name:String;
   }
}

class LoggerKey {}