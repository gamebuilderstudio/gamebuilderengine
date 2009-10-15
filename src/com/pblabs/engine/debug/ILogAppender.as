package com.pblabs.engine.debug
{
	public interface ILogAppender
	{
		function addLogMessage(level:String, loggerName:String, message:String):void;
	}
}