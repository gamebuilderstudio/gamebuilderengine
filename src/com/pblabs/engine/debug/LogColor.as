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
    public class LogColor
    {
        public static const DEBUG:String 	= "#DDDDDD";
        public static const INFO:String 	= "#BBBBBB";
        public static const WARN:String 	= "#FF6600";
        public static const ERROR:String 	= "#FF0000";
        public static const MESSAGE:String 	= "#FFFFFF";
        public static const CMD:String 		= "#00DD00";
        
        public static function getColor(level:String):String
        {
            switch(level)
            {
                case LogEntry.DEBUG:
                    return DEBUG;
                case LogEntry.INFO:
                    return INFO;
                case LogEntry.WARNING:
                    return WARN;
                case LogEntry.ERROR:
                    return ERROR;
                case LogEntry.MESSAGE:
                    return MESSAGE;
                case "CMD":
                    return CMD;
                default:
                    return MESSAGE;
            }
        }
    }
}