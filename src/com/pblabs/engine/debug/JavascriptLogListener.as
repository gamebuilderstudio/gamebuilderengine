package com.pblabs.engine.debug
{
    import flash.external.ExternalInterface;
    
    /**
     * Simple listener to dump log events out to javascript. You might want
     * to customize the name of the function it calls.
     */
    public class JavascriptLogListener implements ILogAppender
    {
        public function addLogMessage(level:String, loggerName:String, message:String):void
        {
            ExternalInterface.call("PBL.log.flash", level, loggerName, message);
        }
    }
}