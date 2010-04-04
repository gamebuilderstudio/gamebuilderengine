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
		public function onShow():void
		{
		}
		
		public function onHide():void
		{
		}
		
		public function onFrame(delta:Number):void
		{
		}
		
		public function onTick(delta:Number):void
		{
		}
	}
}