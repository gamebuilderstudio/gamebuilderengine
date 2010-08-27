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
	import com.pblabs.engine.core.IAnimatedObject;
	import com.pblabs.engine.core.ITickedObject;
	import com.pblabs.engine.entity.IEntity;
	import com.pblabs.engine.entity.PropertyReference;
	
	import flash.geom.Point;
	import flash.utils.describeType;
	import flash.utils.getTimer;

	public class Tween extends Object
	{
		// --------------------------------------------------------------
		// public constants
		// --------------------------------------------------------------
		public static const PROCESS_ONTICK:int = 0;
		public static const PROCESS_ONFRAME:int = 1;
		
		// --------------------------------------------------------------
		// public getter/setter functions
		// --------------------------------------------------------------		
		public function get running():Boolean
		{
			return _running;
		}		
		public function get processInterface():Class
		{
			return _processInterface;
		}		
						
		// --------------------------------------------------------------
		// public methods		
		// --------------------------------------------------------------
		public function Tween( entity:IEntity, object:*, duration:Number, fromVars:* , toVars:*, ease:Function=null, onComplete:Function= null, delay:Number = 0, pingpong:Boolean = false, playCount:int=1, playTime:Number=0, processMode:int = 1)
		{				
			// initialize tweenController
			TweenController.getInstance();			
		
			if (object is String)
				object = new PropertyReference(object);

			// initialize this class
			this.entity = entity;
			if (this.entity == null) 
				this.entity = TweenController.entity;
		    this.object = object;
			this.delay = delay;
			this.duration = duration;
			this.fromVars = fromVars;
			this.toVars = toVars;
			this.pingpong = pingpong;
			// if pingpong provided duration is total pingpong duration
			// so adjust play (ping) duration (half of total duration)
			if (this.pingpong) this.duration = duration*.5;
			this.playCount = playCount;
			this.playTime = playTime;
			// set tweenProcessMode class to right Interface Class
			if (processMode==PROCESS_ONTICK)
				this._processInterface = ITickedObject;
			else
				this._processInterface = IAnimatedObject;
			
			if (ease!=null) this.ease = ease;
			this.onComplete = onComplete;
			// if provided toVars is of a specific type then delta has to be that type as well as well
			if (toVars is Point)
				deltaVars = new Point();
			else
			if (toVars is Object)
				deltaVars = new Object();
			// Tween is not yet running
			_running = false;			
			if (object!=null)
			{
			   // object has been assigned to startup this tween
			   start();						
			   advance(0);
			}			
			TweenController.addTween(this);
		}
		
		public function start():void
		{
			pause = false;
			if (delay<=0) 
			{
				calculateDelta();
				_running = true; 
			}
		} 
		
		public function stop():void
		{
			pause = true;			
			_running = false;
		} 
		
		public function dispose():void
		{
			// remove this tween from Tweencontroller
			if (running) stop();
			TweenController.removeTween(this);			
		} 
		
		public function advance(deltaSecs:Number):Number
		{
			
			var start:int = getTimer();
			var elapsed:int
			
			if (pause || object==null ) return 0;
			// check if there is a delay so we will have to wait
			if (delay>0) 
			{
				// adjust delay
				delay-=deltaSecs;
				if (delay<=0)
				{
					// delay ended, calculate how many time elapsed after delay
					deltaSecs = Math.abs(delay);
					this.start();
				}							  
			}

			// check if we have to advance this tween 
			if (delay<=0)
			{
				if (!advanceDelta(deltaSecs))
				{
					if (onComplete!=null)
						onComplete(this);
					dispose();
					
					elapsed = getTimer() - start;
					return elapsed/1000;
				}
			}				
			else
				_running = false;

								
			elapsed = getTimer() - start;
			return elapsed/1000;
		}
		
		// --------------------------------------------------------------
		// private methods
		// --------------------------------------------------------------
		private function setVar(v:*, vv:*):void
		{
			if (object is PropertyReference)
				entity.setProperty(object,vv);
			else
			  object[v] = vv;
		}
		
	
		private function easeVar(v:String):void
		{
			var vd:*;
			var vf:*;			
			// get variable start value 			
			vf = fromVars[v];			
			// get variable calculated delta value 			
			vd = deltaVars[v];	
			
			var vv:*;
			// ease current value
			if (vf is Point && vd is Point)
			{
				vv = (vf as Point).clone();
				vv.x = ease(secs, vf.x , vd.x, duration);
				vv.y = ease(secs, vf.y , vd.y, duration);				
			}
			else
			  vv = ease(secs, vf , vd, duration);
			// assign eased value to object variable
			setVar(v,vv);
		} 
		
		private function advanceDelta(deltaSecs:Number):Boolean
		{
			var v:String;
			secs += deltaSecs;
			if (secs>duration) 
			{
				if (playCount!=0)
				{
					if (!pingpong || (pingpong && !ping)) 
						if (playCount>0) playCount-=1;
					
					if ((!pingpong && playCount==0) || (pingpong && !ping && playCount==0))
					  secs = duration;
					else
					{
						while (secs > duration)
							secs = secs-duration;
						if (pingpong)
						{
							var tmpVars:* = fromVars;
							fromVars = toVars;
							toVars = tmpVars;
							calculateDelta();
							ping = !ping;
						}
					}
				}
			}
									
			if (secs<=duration)
			{
				if (object is PropertyReference)
				{
					var vv:*;
					if (fromVars is Point && deltaVars is Point)
					{
						vv = (fromVars as Point).clone();
						vv.x = ease(secs, fromVars.x , deltaVars.x, duration);
						vv.y = ease(secs, fromVars.y , deltaVars.y, duration);				
						setVar(object,vv);
					}
					else
					{
						vv = ease(secs, fromVars , deltaVars, duration);
						setVar(object,vv);
					}
				}
				else
					if (toVars is Object)
					{
						for (v in toVars)
						{
							if (object.hasOwnProperty(v))
								easeVar(v);
						}				
					}
				
				totalTimePlayed += deltaSecs;
				if (playTime>0  && totalTimePlayed >= playTime)
					return false;
								
				return true;
			}
			else
			{
				if (object is PropertyReference)
				{
					setVar(object,toVars);
				}
				else
				if (toVars is Object)
				{
					for (v in toVars)
						if (object.hasOwnProperty(v))
						{
							var vt:* = toVars[v];
							setVar(v,vt);
						}
				}
				return false;  
			}   
		} 
		
		private function calculateDelta():void
		{
			var delta:*;
			var vf:*;
			var vt:*;
			if (fromVars==null) 
				fromVars = new Object();
			
			if (object is PropertyReference)
			{
				vf = fromVars;
				vt = toVars;
				if (vf == null)
				{
					vf = entity.getProperty(object,null);
					fromVars = vf;
				}
				if (vf!=null)
				{
					if (vf is Point && vt is Point)
					{
						delta = new Point(0,0);
						delta.x = (vt.x - vf.x);
						delta.y = (vt.y - vf.y);
					}
					else
						delta = (vt-vf);
					deltaVars = delta;		
				}
			}
			else
			if (toVars is Object)
			{
				for (var v:String in toVars)
				{					
					if (fromVars.hasOwnProperty(v))
						vf = fromVars[v];
					else
					{
						if (object.hasOwnProperty(v))
						{
							vf = object[v];
							fromVars[v] = vf;
						}
					}				
					vt = toVars[v];
					if (vf is Point && vt is Point)
					{
						delta = new Point(0,0);
						delta.x = (vt.x - vf.x);
						delta.y = (vt.y - vf.y);
					}
					else
					  delta = (vt-vf);
					deltaVars[v] = delta;		
				}
			}
		}
		
		// --------------------------------------------------------------
		// private variables				
		// --------------------------------------------------------------
		private var object:*;
		private var delay:Number = 0.0;
		private var secs:Number = 0;
		private var duration:Number = 1;
		private var fromVars:*;
		private var toVars:*;
		private var deltaVars:*;
		private var ease:Function = Linear.easeIn;
		private var pause:Boolean = false;
		private var _running:Boolean = false;
		private var onComplete:Function = null;
		private var isPropertyReference:Boolean = false;
		private var entity:IEntity;
		private var _processInterface:Class;

		private var pingpong:Boolean;
		private var playCount:int;
		private var playTime:Number;
		private var ping:Boolean = true;
		
		private var totalTimePlayed:Number = 0;
		
	}
}

class Linear
{		
	public static function easeNone(t:Number, b:Number,
									c:Number, d:Number):Number
	{
		return c * t / d + b;
	}
	public static function easeIn(t:Number, b:Number,
								  c:Number, d:Number):Number
	{
		return c * t / d + b;
	}
	public static function easeOut(t:Number, b:Number,
								   c:Number, d:Number):Number
	{
		return c * t / d + b;
	}
	public static function easeInOut(t:Number, b:Number,
									 c:Number, d:Number):Number
	{
		return c * t / d + b;
	}
}
