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

	/*****************************************************
	 * The TweenComponent can be used to start tweens in an entity.
	 * It can be used to load tween information from template XML.
	 * The tweens can only be linear.
	 */
	public class TweenComponent extends EntityComponent
	{
		/*****************************************************
		 * The object that has to be tweened.
		 * If provided a String value, it will be converted to a PropertyReference.
		 */
		public var object:* = null;

		/*****************************************************
		 * The duration of the tween in seconds.
		 * If 'pingpong' is on , duration is the full pingpong tween. 
		 */
		public var duration:Number = 0;

		/*****************************************************
		 * Set this to true if you want to reverse the tween after it reaches the end value.
		 */
		public var pingpong:Boolean = false;

		/*****************************************************
		 * How many times the tween has to run. 
		 * If 'pingpong' is on the full pingpong tween counts as 1. 
		 */
		public var playCount:int=1;
		
		/*****************************************************
		 * How long the tween has to run in seconds. 
		 */
		public var playTime:Number;

		/*****************************************************
		 * The tween will start after this amount of time (in seconds). 
		 */
		public var delay:Number = 0.0;

		/*****************************************************
		 * Tween start value(s).
		 * If a propertyReference is used, the value is a single value, otherwise
		 * an object with attribute starting values. 
		 */
		public var fromVars:*;

		/*****************************************************
		 * Tween end value(s). 
		 * If a propertyReference is used, the value is a single value, otherwise
		 * an object with attribute starting values. 
		 */
		public var toVars:*;
		/*****************************************************
		 * The modus (Frame or Tick) that is used to advance this tween.
		 * Tween.PROCESS_ONTICK:int  = 0
		 * Tween.PROCESS_ONFRAME:int  = 1
		 */
		public var processMode:int = Tween.PROCESS_ONFRAME; 
		
		/*****************************************************
		 * Set loop to true if the tween has to keep repeating.
		 */
		public function set loop(value:Boolean):void
		{
			playCount = (value)?-1:1;
		}
						
		public function TweenComponent()
		{
			super();
		}
	
		/*****************************************************
		 * The Tween will be automaticly started when this component is added to an entity
		 */
		protected override function onAdd():void
		{
			tween = new Tween(this.owner,object,duration,fromVars,toVars,null,null,delay,pingpong,playCount,playTime,processMode);			
		}

		/*****************************************************
		 * The Tween will be automaticly stopped and cleaned up when this component is removed from an entity
		 */
		protected override function onRemove():void
		{
			dispose();		
		}

		/*****************************************************
		 * Stops and disposes the Tween
		 */
		public function dispose():void
		{
			tween.dispose();		
		}
		
		private var tween:Tween;
		
		
	}
}