package com.pblabs.engine.debug.log4PBE
{
   import flash.utils.Dictionary;
   
   import com.pblabs.engine.resource.*;
   import com.pblabs.engine.serialization.TypeUtility;
   
   /**
    * Singleton class for configuring the logging system. The simplest way to configure the system
    * is by creating an xml file and loading it with the LoadConfiguration method. It can also be
    * configured by calling the various public methods of this class.
    * 
    * <p>This logging system is conceptually based on the log4j logging framework from
    * http://logging.apache.org/log4j/1.2/manual.html
    * </p>
    * 
    * <p>There are four main parts of the logging system. Loggers, levels, filters, and appenders. A
    * logger is the main class that is used to log messages. Each class has its own logger that
    * can be retrieved by calling Logger.getLogger(class), where class is the class that the logger
    * will be used for. Typically this is stored in a static variable on each class that uses
    * logging. Like this:
    * <pre>
    *    private static var _logger:Logger = Logger.getLogger(MyClass);
    * </pre>
    * </p>
    * 
    * <p>A level specifies the severity of a log message. In conjunction with filters, they are
    * used to determine what messages printed to the log should be passed on to the various
    * appenders for processing.
    * <p>Six log levels are created by default. They are:</p>
    * <ul>
    * <li>Trace - Log Level 0</li>
    * <li>Debug - Log Level 20</li>
    * <li>Info - Log Level 40</li>
    * <li>Warn - Log Level 60</li>
    * <li>Error - Log Level 80</li>
    * <li>Fatal - Log Level 100</li>
    * </ul>
    * </p>
    * 
    * <p>A filter specifies which log messages should be processed for a given logger type. Loggers
    * inherit filter settings from there parent, so a filter for class com.pblabs.engine would also
    * apply to com.pblabs.engine.entity unless com.pblabs.engine.entity also had a filter. A filter consists
    * of simply a log level. Any message coming from a logger that the filter is applied to checks
    * the log level of the message against its level. If the severity is the same or higher, the
    * message is processed. Otherwise, it is dropped.
    * </p>
    * 
    * <p>An appender is used to actually process any log messages that make it past their filter
    * and outputs them in some meaningful way. By default a TraceAppender and ExceptionAppender
    * exist. The TraceAppender simply takes the message and calls trace, thereby printing it to the
    * output window. The ExceptionAppender takes any message with a log level of fatal and throws
    * an exception with the message used as the error.
    * </p>
    */
   public class LogManager
   {
      /**
       * The singleton instance.
       */
      public static function get instance():LogManager
      {
         if (!_instance)
         {
            _instance = new LogManager(new LogManagerKey());
            _logger = _instance.getLogger(LogManager);
         }
         
         return _instance;
      }
      
      private static var _instance:LogManager;
      private static var _logger:Logger;
      
      /**
       * Creates a LogManager. Use the static instance property to retrieve the LogManager rather
       * than using this directly.
       */
      public function LogManager(key:LogManagerKey)
      {
         if (!key)
            throw new Error("LogManagers cannot be created manually! Use the static instance property.");
         
         ExceptionAppender;
         TraceAppender;
         UIAppender;
         
         addLogLevel("trace", 0);
         addLogLevel("debug", 20);
         addLogLevel("info", 40);
         addLogLevel("warn", 60);
         addLogLevel("error", 80);
         addLogLevel("fatal", 100);
      }
      
      /**
       * Registers an array of messages in a table to be used for messages coming from a particular
       * package. Once registered, it isn't required to use, but will be used for any message coming
       * from a logger inside the specified package that starts with '#' and a number. The very
       * first entry in the registered table should be a string starting with '#' followed by a
       * number. This number is treated as an offset for the package. So, if the offset is 2000,
       * the first entry in the message table would be accessed by sending a log message of #2001.
       * 
       * @param packageName The name of the package to use the table for. A logger will search for
       * the best match packageName when searching for a log table.
       * @param table An array of strings containing log messages to use for the specified package.
       */
      public function registerMessageTable(packageName:String, table:Array):void
      {
         // validate
         if (_logTables[packageName])
         {
            _logger.warn("A log table has already been registered for the package %1.", packageName);
            return;
         }
         
         // create the table
         var logTable:LogTable = new LogTable(table);
         
         // make sure the table is of the correct form
         if (!logTable.isValid)
         {
            _logger.warn("The log table registered for the package %1 is invalid.", packageName);
            return;
         }
         
         _logTables[packageName] = logTable;
      }
      
      /**
       * Loads an xml file and reads a log configuration from it. If a configuration file is
       * being used, it should be loaded before the application does anything else. Otherwise,
       * log messages that are printed before loading will not respect the settings in the
       * configuration file. The onComplete function exists so all processing can be deferred
       * until after the file is completely loaded.
       * 
       * @param filename The file to read the configuration from.
       * 
       * <p>The configuration file can contain four different tags. These are appender, level,
       * default, and filter. Additionally, there are two attrubutes that can be specified on
       * the root tag: trackLevel and trackNumber.
       * </p>
       * 
       * <p>Track level specifies the level of objects to track for duplicates. Track number
       * specifies the number of messages to keep in the track queue. Any message that exists
       * in the track queue at a level equal to or higher than the track level will be
       * discarded. This is useful for messages that tend to spam every frame.
       * </p>
       * 
       * <p>The appender tag defines an appender that the application will use.
       * It must have the attributes name and type defined, which specify the name to reference
       * the appender by from the loggers, and the fully qualified type name of the appender.
       * </p>
       * 
       * <p>The level tag can be used to specify additional log levels other than the six that
       * are defined by default. It must have the attributes name and value defined, where name
       * is the name of the level to use when printing log messages, and value is the severity
       * of the level.
       * </p>
       * 
       * <p>The default tag is used to specify the filter properties for the root logger, which
       * is used for loggers that don't have their own filter properties defined. It contains
       * a level tag that defines the level at which messages will be filtered, and any number
       * of appender tags that define the appenders that will be used to process messages that
       * use the root filter.
       * </p>
       * 
       * <p>The filter tag is used just like the default tag, and is used to specify filter
       * settings for loggers other than the default. The name attribute specifies the name of
       * the loggers to use the filter for.
       * </p>
       */
      public function loadConfiguration(filename:String, forceReload:Boolean=false):void
      {
         // force queuing of messages until the configuration is loaded
         _started = false;
         _configuring = true;
         
         // load up the file as an XMLResource
         // forceReload can be specified to re-configure mid-execution
         ResourceManager.instance.load(filename, XMLResource, onConfigurationLoaded, onConfigurationLoadFailed, forceReload);
      }
      
      private function onConfigurationLoaded(resource:XMLResource):void
      {
         // clear out any default configuring
         clearConfiguration();
         
         // load manager values
         if (resource.XMLData.@trackLevel.toString() != "")
            _trackLevel = resource.XMLData.@trackLevel;
         
         if (resource.XMLData.@trackNumber.toString() != "")
            _trackNumber = resource.XMLData.@trackNumber;
         
         // create the appenders
         for each (var appenderXML:XML in resource.XMLData.child("appender"))
         {
            var appenderName:String = appenderXML.@name;
            var appenderType:String = appenderXML.@type;
            
            var appender:* = TypeUtility.instantiate(appenderType);
            if (appender == null)
            {
               _logger.error("Unable to instantiate the type %1 for the appender %2. The class was not found.", appenderType, appenderName);
               continue;
            }
            
            // make sure it's an appender
            if (!(appender is LogAppender))
            {
               _logger.error("The type %1 for the appender %2 is not a LogAppender subclass.", appenderType, appenderName);
               continue;
            }
            
            // add it - this will validate the name
            addLogAppender(appenderName, appender as LogAppender);
         }
         
         // create the levels
         for each (var levelXML:XML in resource.XMLData.child("level"))
         {
            var levelName:String = levelXML.@name;
            var levelValue:int = parseInt(levelXML.@value);
            if (isNaN(levelValue))
            {
               _logger.error("The value for the log level %1 is not a number.", levelName);
               continue;
            }
            
            // add it - this will validate the name
            addLogLevel(levelName, levelValue);
         }
         
         // create the default filter
         for each (var defaultXML:XML in resource.XMLData.child("default"))
         {
            var defaultName:String = "root";
            var defaultLevel:String = defaultXML.level.toString();
            
            // these things are all validated as they are used, since the level or appender
            // could be created later
            var defaultFilter:LogFilter = new LogFilter(defaultName, defaultLevel);
            
            for each (var defaultAppenderXML:XML in defaultXML.child("appender"))
               defaultFilter.addAppender(defaultAppenderXML.toString());
            
            setRootFilter(defaultFilter);
         }
         
         // create the custom filters
         for each (var filterXML:XML in resource.XMLData.child("filter"))
         {
            var filterName:String = filterXML.@name;
            var filterLevel:String = filterXML.level.toString();
            
            // these things are all validated as they are used, since the level or appender
            // could be created later
            var filter:LogFilter = new LogFilter(filterName, filterLevel);
            
            for each (var filterAppenderXML:XML in filterXML.child("appender"))
               filter.addAppender(filterAppenderXML.toString());
            
            // add it - this will validate the name
            addLogFilter(filterName, filter);
         }
         
         start();
      }
      
      private function onConfigurationLoadFailed(resource:XMLResource):void
      {
         _logger.error("Failed to load configuration from file %1.", resource.filename);
         _configuring = false;
         loadDefaultConfiguration();
      }
      
      /**
       * Starts the logging system with default settings. This is a log level of Info with UI and
       * Trace appenders.
       */
      public function loadDefaultConfiguration():void
      {
         // Global calls start in case no configuration is set. If it is, this will be true, and
         // thus that call will do nothing.
         if (_configuring)
            return;
         
         clearConfiguration();
         
         addLogAppender("UI", new UIAppender());
         addLogAppender("Trace", new TraceAppender());
         
         _RootFilter.addAppender("UI");
         _RootFilter.addAppender("Trace");
         
         start();
      }
      
      private function clearConfiguration():void
      {
         for (var appenderName:String in _appenders)
         {
            _appenders[appenderName] = null;
            delete _appenders[appenderName];
         }
      }
      
      /**
       * This is called to startup the logging process. Any log message added before this is called
       * will be queued up and printed when this is called. This enables log messages to be printed
       * prior to all the configuration settings being set.
       * 
       * <p>This is called automatically when the configuration file has finished loading.</p>
       */
      public function start():void
      {
         _started = true;
         for each (var message:Object in _queuedMessages)
            addLogMessage(message.levelName, message.logger, message.message, message.arguments);
         
         _queuedMessages.splice(0, _queuedMessages.length);
      }
      
      /**
       * Adds a LogAppender with a given name.
       * 
       * @param name The name to assign the appender.
       * @param appender The LogAppender to add.
       */
      public function addLogAppender(name:String, appender:LogAppender):void
      {
         // validate
         if (!appender)
         {
            _logger.error("Cannot register a null appender with name %1.", name);
            return;
         }
         
         if (name == null || name == "")
         {
            _logger.error("An empty name cannot be used for appenders.");
            return;
         }
         
         if (_appenders[name])
         {
            _logger.warn("An appender with name %1 already exists.", name);
            return;
         }
         
         _appenders[name] = appender;
      }
      
      internal function getLogAppender(name:String):LogAppender
      {
         return _appenders[name];
      }
      
      /**
       * Adds a log level with the specified name and severity.
       * 
       * @param name The name to assign the level. Names are not case-sensitive.
       * @param level The severity to assign the level.
       */
      public function addLogLevel(name:String, level:int):void
      {
         // convert to upper case to maintain case insensitivity
         var cappedName:String = name.toUpperCase();
         
         // validate
         if (name == null || name == "")
         {
            _logger.error("An empty name cannot be used for levels.");
            return;
         }
         
         if (_levels[cappedName])
         {
            _logger.warn("A level with name %1 already exists.", name);
            return;
         }
         
         _levels[cappedName] = new LogLevel(cappedName, level);
      }
      
      internal function getLogLevel(name:String):LogLevel
      {
         // convert to upper case to maintain case insensitivity
         name = name.toUpperCase();
         return _levels[name];
      }
      
      /**
       * Sets the filter to use for all loggers that do not have their own filter
       * defined.
       * 
       * @param filter The filter to use as the root.
       */
      public function setRootFilter(filter:LogFilter):void
      {
         // validate
         if (!filter)
         {
            _logger.error("Cannot register a null filter as the root filter.");
            return;
         }
         
         filter._isRoot = true;
         _rootFilter = filter;
      }
      
      /**
       * Adds a filter to use for loggers with the specified name. The filter with the most
       * correct name is used for each logger. Meaning, a filter with name
       * com.pblabs.engine.entity.EntityComponent will be used for the EntityComponent class'
       * logger if it is registered, even if a filter with name com.pblabs.engine.entity is also
       * registered.
       */
      public function addLogFilter(name:String, filter:LogFilter):void
      {
         // validate
         if (!filter)
         {
            _logger.error("Cannot register a null filter with name %1.", name);
            return;
         }
         
         if (name == null || name == "")
         {
            _logger.error("An empty name cannot be used for filters.");
            return;
         }
         
         if (_filters[name])
         {
            _logger.warn("A filter with name %1 already exists.", name);
            return;
         }
         
         _filters[name] = filter;
      }
      
      internal function getLogFilter(name:String):LogFilter
      {
         return _filters[name];
      }
      
      internal function getLogFilterFor(name:String):LogFilter
      {
         while (!_filters[name])
         {
            // if there's no dot, this was a top level package, so the only thing
            // left is the root
            var dotIndex:int = name.lastIndexOf(".");
            if (dotIndex == -1)
               return _RootFilter;
            
            // search the next package up
            name = name.substring(0, dotIndex);
         }
         
         return _filters[name];
      }
      
      internal function getLogger(classType:*):Logger
      {
         if (classType == null)
         {
            _logger.error("Unable to create a logger with a null class type.");
            return null;
         }
         
         // if a string is passed, treat it as the class name, otherwise get the class name
         // of the object that was passed in
         var className:String;
         if (classType is String)
         {
            if (classType == "")
            {
               _logger.error("Unable to create a logger with an empty class type.");
               return null;
            }
            
            className = classType;
         }
         else
         {
            // for Class objects, this returns the correct class name, rather than 'Class'.
            className = TypeUtility.getObjectClassName(classType);
            
            // the package and type name is separated by :: instead of .
            className = className.replace("::", ".");
         }
         
         // don't recreate if it already exists
         if (!_loggers[className])
            _loggers[className] = Logger.create(className);
         
         return _loggers[className];
      }
      
      internal function addLogMessage(levelName:String, logger:Logger, message:String, arguments:Array):void
      {
         if (!_started)
         {
            _queuedMessages.push({levelName:levelName, logger:logger, message:message, arguments:arguments});
            return;
         }
         
         // get and validate the filter and level
         var filter:LogFilter = getLogFilterFor(logger.name);
         
         var level:LogLevel = getLogLevel(levelName);
         if (!level)
         {
            _logger.error("Unable to find the level with name %1 for the logger %2.", levelName, logger.name);
            return;
         }
         
         // we could call isLoggerEnabledFor, but we need the filter and level anyway
         // if the logger isn't enabled for the specified level, just ignore the message
         if (filter.shouldFilter(level))
            return;
         
         var errorNumber:int = -1;
         var logTable:LogTable = getLogTable(logger);
         if (logTable)
         {
            errorNumber = logTable.getErrorNumber(message);
            
            // check if this message has been printed recently
            if (!shouldAdd(level, errorNumber))
               return;
            
            message = logTable.translateMessage(message, errorNumber);
         }
         
         for each (var appenderName:String in filter.appenders)
         {
            var appender:LogAppender = getLogAppender(appenderName);
            if (!appender)
            {
               _logger.error("The appender %1 was not found for the filter %2.", appenderName, filter.name);
               continue;
            }
            
            appender.addLogMessage(levelName.toUpperCase(), logger.name, errorNumber, message, arguments);
         }
      }
      
      private function shouldAdd(level:LogLevel, errorNumber:int):Boolean
      {
         // not going to compare messages, so only decline if there's a valid error number
         if (errorNumber < 0)
            return true;
         
         var trackLevel:LogLevel = getLogLevel(_trackLevel);
         
         // check if tracking is turned off
         if (!trackLevel || _trackNumber < 1)
            return true;
         
         // only watch things with levels higher than the track level
         if (trackLevel.compare(level) < 0)
            return true;
         
         var add:Boolean = true;
         for each (var trackedNumber:int in _trackedMessages)
         {
            // same message from same logger means don't add
            if (trackedNumber == errorNumber)
            {
               add = false;
               break;
            }
         }
         
         // modify the queue
         _trackedMessages.push(errorNumber);
         while (_trackedMessages.length > _trackNumber)
            _trackedMessages.shift();
         
         return add;
      }
      
      internal function isLoggerEnabledFor(logger:Logger, levelName:String):Boolean
      {
         var level:LogLevel = getLogLevel(levelName);
         if (!level)
         {
            _logger.error("Unable to find the level with name %1 for the class %2.", levelName, logger.name);
            return false;
         }
         
         var filter:LogFilter = getLogFilterFor(logger.name);
         return !filter.shouldFilter(level);
      }
      
      private function getLogTable(logger:Logger):LogTable
      {
         var name:String = logger.name;
         while (!_logTables[name])
         {
            var dotIndex:int = name.lastIndexOf(".");
            if (dotIndex == -1)
               return null;
            
            // search for the next package up
            name = name.substring(0, dotIndex);
         }
         
         return _logTables[name];
      }
      
      // has to exist like this so the LogFilter class can have a logger
      // also, it forces a root filter to always exist, which is nice
      private function get _RootFilter():LogFilter
      {
         if (!_rootFilter)
         {
            _rootFilter = new LogFilter("root", "info")
            _rootFilter._isRoot = true;
         }
         
         return _rootFilter;
      }
      
      private var _rootFilter:LogFilter;
      
      private var _logTables:Dictionary = new Dictionary();
      
      private var _loggers:Dictionary = new Dictionary();
      private var _filters:Dictionary = new Dictionary();
      private var _levels:Array = new Array();
      private var _appenders:Dictionary = new Dictionary();
      
      private var _started:Boolean = false;
      private var _configuring:Boolean = false;
      private var _queuedMessages:Array = new Array();
      
      private var _trackLevel:String = "Warn";
      private var _trackNumber:int = 10;
      private var _trackedMessages:Array = new Array();
   }
}

class LogTable
{
   public function LogTable(table:Array)
   {
      _offset = parseIndex(table[0]);
      _table = table;
   }
   
   public function get isValid():Boolean
   {
      return _offset >= 0 && _table;
   }
   
   private function parseIndex(message:String):int
   {
      // messages referencing tables use # followed by the number
      if (message.charAt(0) != "#")
         return -1;
      
      // if the message isn't a number, this will return NaN
      var index:int = parseInt(message.substring(1));
      if (isNaN(index))
         return -1;
      
      // for parsing the offset
      if (!_table)
         return index;
      
      // validate it's in the table
      index -= _offset
      if (index < 0 || index >= _table.length)
         return -1;
      
      return index;
   }
   
   public function getErrorNumber(message:String):int
   {
      var index:int = parseIndex(message);
      return index >= 0 ? index + _offset : -1;
   }
   
   public function translateMessage(message:String, errorNumber:int):String
   {
      var index:int = errorNumber - _offset;
      if (index < 0 || index >= _table.length)
         return message;
      
      return _table[index];
   }
   
   private var _offset:int = 0;
   private var _table:Array = null;
}

class LogManagerKey {}