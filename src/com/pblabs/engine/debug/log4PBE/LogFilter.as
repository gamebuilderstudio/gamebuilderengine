package com.pblabs.engine.debug.log4PBE
{
   public class LogFilter
   {
      private static var _logger:Logger = Logger.getLogger(LogFilter);
      
      public function LogFilter(name:String, level:String)
      {
         _name = name;
         _level = level;
      }
      
      public function get parent():LogFilter
      {
         // the root node doesn't have a parent
         if (_isRoot)
            return null;
         
         var name:String = _name.substring(0, _name.lastIndexOf("."));
         return LogManager.instance.getLogFilterFor(name);
      }
      
      public function get name():String
      {
         return _name;
      }
      
      public function get appenders():Array
      {
         // append the parent appenders to this list of appenders
         var parent:LogFilter = this.parent;
         if (!parent)
            return _appenders.concat();
         
         return _appenders.concat(parent.appenders);
      }
      
      public function addAppender(name:String):void
      {
         // validate
         if (name == null || name == "")
         {
            _logger.warn("Cannot add an empty appender to the filter %1.", _name);
            return;
         }
         
         if (_appenders.indexOf(name) != -1)
         {
            _logger.warn("The appender %1 has already been added to the filter %2.", name, _name);
            return;
         }
         
         _appenders.push(name);
      }
      
      public function shouldFilter(level:LogLevel):Boolean
      {
         var myLevel:LogLevel = LogManager.instance.getLogLevel(_level);
         
         // validate
         if (!myLevel)
         {
            _logger.error("Unable to find the level %1 for the filter %2.", _level, _name);
            return false;
         }
         
         return myLevel.compare(level) < 0;
      }
      
      // set in LogManager.SetRootFilter
      internal var _isRoot:Boolean = false;
      
      private var _name:String;
      private var _level:String;
      private var _appenders:Array = [];
   }
}