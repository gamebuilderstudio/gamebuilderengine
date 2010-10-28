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
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.components.TickedComponent;
	import com.pblabs.engine.core.IAnimatedObject;
	import com.pblabs.engine.core.ITickedObject;
	import com.pblabs.engine.debug.Console;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.entity.EntityComponent;
	import com.pblabs.engine.entity.IEntity;
	
	import flash.utils.getTimer;
	
	public class TweenController extends EntityComponent implements ITickedObject, IAnimatedObject
	{
		public static var entity:IEntity = null;

		// -----------------------------------------------------------------
		// getter/setter functions
		// -----------------------------------------------------------------
		
		public static function tweenCount(processInterface:Class = null):int
		{
			switch (processInterface)
			{
				case ITickedObject: return instance.tickTweens.length;
				case IAnimatedObject: return instance.frameTweens.length;				
			}
			return instance.frameTweens.length+instance.tickTweens.length;
		}
							
		private static function get instance():TweenController
		{
			if (_instance==null)
			{
				// singleton instance of this classhas to be created
				_instance = new TweenController();
				// create an PBE entity associated with this static class
				// to do general PropertyReference lookups
				entity = PBE.allocateEntity();
				entity.initialize("TweenControllerEntity");
				entity.addComponent(_instance,"controller");
				// register this class with the processmanager
				// for onTick and onFrame callbacks
				PBE.processManager.addAnimatedObject(_instance);
				PBE.processManager.addTickedObject(_instance);							
			}			
			return _instance;
		}

		// -----------------------------------------------------------------
		// Public methods
		// -----------------------------------------------------------------
		
		public function TweenController()
		{			
		}

		public static function getInstance():TweenController
		{
			return instance;
		}	
		
		public static function addTween(tween:Tween):void
		{						
			switch(tween.processInterface)
			{
				case ITickedObject:
					instance.tickTweens.push(tween);
				break;
				case IAnimatedObject:
					instance.frameTweens.push(tween);
				break;
			}			
		}	
		
		public static function removeTween(tween:Tween):void
		{	
			var tweenIndex:int; 
			switch(tween.processInterface)
			{
				case ITickedObject:
					tweenIndex = instance.tickTweens.indexOf(tween);
					if (tweenIndex>=0)
						instance.tickTweens.splice(tweenIndex,1);
					break;
				case IAnimatedObject:
					tweenIndex = instance.frameTweens.indexOf(tween);
					if (tweenIndex>=0)
						instance.frameTweens.splice(tweenIndex,1);
					break;
			}						
		}	
		
		public function onTick(deltaTime:Number):void
		{
			if (tickTweens.length>0)
			{
				var baseTime:int = getTimer();
				for (var t:int = 0; t<tickTweens.length; t++)
					(tickTweens[t] as Tween).advance(deltaTime+((getTimer()-baseTime)/1000));				
			}
		}
		
		public function onFrame(deltaTime:Number):void
		{
			if (frameTweens.length>0)
			{
				var baseTime:int = getTimer();
				for (var t:int = 0; t<frameTweens.length; t++)
					(frameTweens[t] as Tween).advance(deltaTime+((getTimer()-baseTime)/1000));				
			}
		}
		
		// -----------------------------------------------------------------
		// Private variables
		// -----------------------------------------------------------------
		private static var _instance:TweenController = null		
		private var tickTweens:Array = new Array();
		private var frameTweens:Array = new Array();
		
	}		
}