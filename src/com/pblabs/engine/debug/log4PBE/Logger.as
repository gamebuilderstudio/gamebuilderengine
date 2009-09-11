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
      public static function getLogger(classType:*):Logger
      {
         // grab from the logger so it can return a cached version if necessary
         return LogManager.instance.getLogger(classType);
      }
      
      internal static function create(name:String):Logger
      {
         // this exists so the LogManager can create Loggers, but nothing outside can
         return new Logger(name, new LoggerKey());
      }
      
      /**
       * Creates a Logger. Use the static getLogger method to create a Logger rather than
       * using this directly.
       */
      public function Logger(name:String, key:LoggerKey)
      {
         // uncomment this when we move to flex style - right now there's a conflict with the error method
         if (!key)
            throw new Error("Loggers cannot be created manually! Use the static getLogger method instead.");
         
         _name = name;
      }
      
      /**
       * The name of the Logger.
       */
      public function get name():String
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
      public function isEnabledFor(level:String):Boolean
      {
         return LogManager.instance.isLoggerEnabledFor(this, level);
      }
      
      /**
       * Outputs a log message at the "trace" level.
       * 
       * @param message The message to print. This can include %# markers as replacement locations
       * for subsequent arguments. For instance, '%1' would be replaced by the first additional
       * parameter passed to the method, and '%4' would be replaced by the fourth.
       */
      public function trace(message:String, ...arguments:Array):void
      {
         LogManager.instance.addLogMessage("trace", this, message, arguments);
      }
      
      /**
       * Outputs a log message at the "debug" level.
       * 
       * @param message The message to print. This can include %# markers as replacement locations
       * for subsequent arguments. For instance, '%1' would be replaced by the first additional
       * parameter passed to the method, and '%4' would be replaced by the fourth.
       */
      public function debug(message:String, ...arguments:Array):void
      {
         LogManager.instance.addLogMessage("debug", this, message, arguments);
      }
      
      /**
       * Outputs a log message at the "info" level.
       * 
       * @param message The message to print. This can include %# markers as replacement locations
       * for subsequent arguments. For instance, '%1' would be replaced by the first additional
       * parameter passed to the method, and '%4' would be replaced by the fourth.
       */
      public function info(message:String, ...arguments:Array):void
      {
         LogManager.instance.addLogMessage("info", this, message, arguments);
      }
      
      /**
       * Outputs a log message at the "warn" level.
       * 
       * @param message The message to print. This can include %# markers as replacement locations
       * for subsequent arguments. For instance, '%1' would be replaced by the first additional
       * parameter passed to the method, and '%4' would be replaced by the fourth.
       */
      public function warn(message:String, ...arguments:Array):void
      {
         LogManager.instance.addLogMessage("warn", this, message, arguments);
      }
      
      /**
       * Outputs a log message at the "error" level.
       * 
       * @param message The message to print. This can include %# markers as replacement locations
       * for subsequent arguments. For instance, '%1' would be replaced by the first additional
       * parameter passed to the method, and '%4' would be replaced by the fourth.
       */
      public function error(message:String, ...arguments:Array):void
      {
         LogManager.instance.addLogMessage("error", this, message, arguments);
      }
      
      /**
       * Outputs a log message at the "fatal" level.
       * 
       * @param message The message to print. This can include %# markers as replacement locations
       * for subsequent arguments. For instance, '%1' would be replaced by the first additional
       * parameter passed to the method, and '%4' would be replaced by the fourth.
       */
      public function fatal(message:String, ...arguments:Array):void
      {
         LogManager.instance.addLogMessage("fatal", this, message, arguments);
      }
      
      /**
       * Outputs a log message at the specified level.
       * 
       * @param level The level to output the message at.
       * @param message The message to print. This can include %# markers as replacement locations
       * for subsequent arguments. For instance, '%1' would be replaced by the first additional
       * parameter passed to the method, and '%4' would be replaced by the fourth.
       */
      public function log(level:String, message:String, ...arguments:Array):void
      {
         LogManager.instance.addLogMessage(level, this, message, arguments);
      }
      
      private var _name:String;
   }
}

class LoggerKey {}