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
	import com.pblabs.engine.entity.EntityComponent;
	public class TweenComponent extends EntityComponent
	{
		public var object:* = null;
		public var duration:Number = 0;
		public var pingpong:Boolean = false;
		public var playCount:int=1;
		public var playTime:Number;
		public var delay:Number = 0.0;
		public var fromVars:*;
		public var toVars:*;
		public var processMode:int = Tween.PROCESS_ONFRAME; 
		
		public function set loop(value:Boolean):void
		{
			playCount = (value)?-1:1;
		}
			
		
		public function set active(value:Boolean):void
		{
			if (value)
			{
				new Tween(this.owner,object,duration,fromVars,toVars,null,null,delay,pingpong,playCount,playTime,processMode);
			}
		}
		
		public function TweenComponent()
		{
			super();
		}		
		
	}
}