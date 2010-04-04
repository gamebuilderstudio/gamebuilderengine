/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.debug
{
    import flash.external.ExternalInterface;
    
    /**
     * Simple listener to dump log events out to javascript. You might want
     * to customize the name of the function it calls.
     * 
     * Note that this can be an expensive listener to have active. We have
     * observed that it can take as much as 6ms to log one output line. So,
     * you may only want to use this listener when necessary.
     */
    public class JavascriptLogListener implements ILogAppender
    {
        public function addLogMessage(level:String, loggerName:String, message:String):void
        {
            ExternalInterface.call("PBL.log.flash", level, loggerName, message);
        }
    }
}