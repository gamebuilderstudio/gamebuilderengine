/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.animation
{
	/**
     * Class for animating between a (spriteSheet) start frame and end frame.
     */
    public class FrameAnimator extends Animator
    {

		//--------------------------------------------------------------------------
		//
		//  publid properties (getters/setter)
		//
		//--------------------------------------------------------------------------
		
		public function get startFrame():int
		{
			return _startFrame;						
		}
		public function get endFrame():int
		{
			return _endFrame;			
		}		
		public function set startFrame(value:int):void
		{
			_startFrame = value;
			startValue = value-1;
		}
		public function set endFrame(value:int):void
		{
			_endFrame = value;
			targetValue = _endFrame-0.0001;
		}		
		//--------------------------------------------------------------------------
		//
		//  private Variables
		//
		//--------------------------------------------------------------------------						
		private var _startFrame:int;
		private var _endFrame:int;		
	}
}
