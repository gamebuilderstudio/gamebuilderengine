package com.pblabs.engine.debug.log4PBE
{
   public class LogFilter
   {
      private static var _logger:Logger = Logger.GetLogger(LogFilter);
      
      public function LogFilter(name:String, level:String)
      {
         _name = name;
         _level = level;
      }
      
      public function get Parent():LogFilter
      {
         // the root node doesn't have a parent
         if (_isRoot)
            return null;
         
         var name:String = _name.substring(0, _name.lastIndexOf("."));
         return LogManager.Instance.GetLogFilterFor(name);
      }
      
      public function get Name():String
      {
         return _name;
      }
      
      public function get Appenders():Array
      {
         // append the parent appenders to this list of appenders
         var parent:LogFilter = Parent;
         if (!parent)
            return _appenders.concat();
         
         return _appenders.concat(parent.Appenders);
      }
      
      public function AddAppender(name:String):void
      {
         // validate
         if (name == null || name == "")
         {
            _logger.Warn("Cannot add an empty appender to the filter %1.", _name);
            return;
         }
         
         if (_appenders.indexOf(name) != -1)
         {
            _logger.Warn("The appender %1 has already been added to the filter %2.", name, _name);
            return;
         }
         
         _appenders.push(name);
      }
      
      public function ShouldFilter(level:LogLevel):Boolean
      {
         var myLevel:LogLevel = LogManager.Instance.GetLogLevel(_level);
         
         // validate
         if (!myLevel)
         {
            _logger.Error("Unable to find the level %1 for the filter %2.", _level, _name);
            return false;
         }
         
         return myLevel.Compare(level) < 0;
      }
      
      // set in LogManager.SetRootFilter
      internal var _isRoot:Boolean = false;
      
      private var _name:String;
      private var _level:String;
      private var _appenders:Array = [];
   }
}