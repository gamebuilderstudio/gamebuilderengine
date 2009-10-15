package com.pblabs.engine.debug
{
    
    /**
     * Simply dump log activity via trace(). 
     */
    public class TraceAppender implements ILogAppender
    {
        public function addLogMessage(level:String, loggerName:String, message:String):void
        {
            trace(level + ": " + loggerName + " - " + message);
        }
    }
}