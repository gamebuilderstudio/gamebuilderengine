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
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.core.InputKey;
	import com.pblabs.engine.core.InputManager;
	
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	/**
	 * LogAppender for displaying log messages in a LogViewer. The LogViewer will be
     * attached and detached from the main view when the defined hot key is pressed. The tilde (~) key 
	 * is the default hot key.
	 */	
	public class UIAppender implements ILogAppender
	{
		protected var _logViewer:LogViewer;
	   
		public function UIAppender()
		{
			PBE.inputManager.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			_logViewer = new LogViewer();
		}
  
		private function onKeyDown(event:KeyboardEvent):void
		{
			if (event.keyCode != Console.hotKeyCode)
				return;
			 
			if(_logViewer)
			{
				if (_logViewer.parent)
				{
					_logViewer.parent.removeChild(_logViewer);
					_logViewer.deactivate();
				}
				else
				{
					PBE.mainStage.addChild(_logViewer);
					var char:String = String.fromCharCode(event.charCode);
					_logViewer.restrict = "^"+char.toUpperCase()+char.toLowerCase();	// disallow hotKey character
					_logViewer.activate();
				}
			}
		}
  
		public function addLogMessage(level:String, loggerName:String, message:String):void
		{
			if(_logViewer)
			_logViewer.addLogMessage(level, loggerName, message);
		}
	}
}