package com.pblabs.engine.debug
{
	public class LogColor
	{
		public static const TRACE:String = "#000000";
		public static const DEBUG:String = "#0000CD";
		public static const INFO:String = "#008000";
		public static const WARN:String = "#FFCC33";
		public static const ERROR:String = "#FF0000";
		public static const FATAL:String = "#FF4500";
		
		public static function getColor(level:String):String
		{
			switch(level)
			{
				case "TRACE":
					return TRACE;
				case "DEBUG":
					return DEBUG;
				case "INFO":
					return INFO;
				case "WARN":
					return WARN;
				case "ERROR":
					return ERROR;
				case "FATAL":
					return FATAL;
				default:
					return TRACE;
			}
		}
	}
}