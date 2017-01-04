/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.screens
{
    import flash.display.Sprite;

    /**
     * Most basic implementation of IScreen. You will probably want to use a
     * subclass.
     */
	public class BaseScreen extends Sprite implements IScreen
	{
		private var _hideTransition:String;
		private var _showTransition:String;
		private var _hideDelay:Number;
		private var _showDelay:Number;

		public function get showTransition():String
		{
			return _showTransition;
		}

		public function set showTransition(value:String):void
		{
			_showTransition = value;
		}

		public function get showDelay():Number
		{
			return _showDelay;
		}

		public function set showDelay(value:Number):void
		{
			_showDelay = value;
		}

		public function get hideTransition():String
		{
			return _hideTransition;
		}
		
		public function set hideTransition(value:String):void
		{
			_hideTransition = value;
		}
		
		public function get hideDelay():Number
		{
			return _hideDelay;
		}
		
		public function set hideDelay(value:Number):void
		{
			_hideDelay = value;
		}
		
		public function onShow():void
		{
			performShowTransition();
		}
		
		public function onHide():void
		{
			performHideTransition();
		}
		
		public function onFrame(delta:Number):void
		{
		}
		
		public function onTick(delta:Number):void
		{
		}
		
		protected function performShowTransition():void
		{
			// TODO Auto Generated method stub
		}
		
		protected function performHideTransition():void
		{
			// TODO Auto Generated method stub
			
		}
	}
}