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
   public class ExceptionAppender implements ILogAppender
   {
	   public function addLogMessage(level:String, loggerName:String, message:String):void
	   {
		   if (level != "FATAL")
			   return;
		   
		   throw new Error(message);
	   }
	   
     /* public function addLogMessage(level:String, loggerName:String, message:String, arguments:Array):void
      {
         if (level != "FATAL")
            return;
         
         var numberString:String = "";
         if (errorNumber >= 0)
            numberString = "Error #" + errorNumber;
         
         throw new Error(numberString + replace(message, arguments));
      }*/
   }
}