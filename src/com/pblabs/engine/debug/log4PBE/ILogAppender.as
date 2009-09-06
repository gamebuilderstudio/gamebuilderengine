package com.pblabs.engine.debug.log4PBE
{
	public interface ILogAppender
	{
		function addLogMessage(level:String, loggerName:String, errorNumber:int, message:String, arguments:Array):void;
	}
}