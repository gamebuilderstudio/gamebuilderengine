package com.pblabs.engine.core
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.core.ITickedObject;
	import com.pblabs.engine.debug.Logger;
	
	import org.osflash.signals.Signal;
	
	/**
	 * An engine timer object that times in with the engines' virtual time.
	 * Using this object is more optimized than creating a bunch of native Flash timer objects
	 * and functions the same way.
	 * 
	 * Each timer tick is dispatched using a Signal instead of generating events.
	 **/
	public final class PBTimerObject implements ITickedObject
	{
		/**
		 * An event signal used to notify of progress each tick.
		 **/
		public var onTickSignal : Signal = new Signal();
		/**
		 * The amount of time to wait before the next timer interval/tick
		 **/
		public var delay : Number = 0;
		/**
		 * The amount of times to start the timer over again. If repeat count is 0 this timer will repeat continuously
		 **/
		public var repeatCount : int = 0;
		
		/**
		 * The max amount of time the timer should run. If the limit is 0 no elapsed time will be counted to trigger a timer stop.
		 **/
		public var limit : Number = 0;
		
		private var _initialStart : Boolean = true;
		private var _startTime : Number = 0;
		private var _running : Boolean = false;
		private var _activeCount : int = 0;
		private var _overallPastTime : Number = 0;
		private var _addedToProcessManager : Boolean = false;
		private var _destroyed : Boolean = false;
		private var _ignoreTimeScale : Boolean = false;
		
		public function onTick(deltaTime:Number):void{
			
			if(!_running) return;
			
			
			if(_activeCount >= repeatCount && repeatCount > 0) 
			{
				stop();
			}
			
			if(_running){
				var _currentTime : Number = _ignoreTimeScale ? PBE.processManager.platformTime : PBE.processManager.virtualTime;
				_overallPastTime = _currentTime - _startTime;
				if(delay <= 0 && limit > 0){
				//Executes timer For A certain limit of time.
					if(_overallPastTime <= limit)
					{
						advanceTimerTick(_currentTime);
					}else{
						stop();
					}
				}else{
				//Checks for a certain amount of elapsed time (delay) before ticking timer
					if(delay >= _overallPastTime)
					{
						advanceTimerTick(_currentTime, true);
					}
				}
			}
		}
		
		private function advanceTimerTick(currentTime : Number, resetTimeCount : Boolean = false):void
		{
			onTickSignal.dispatch();
			_activeCount++;
			if(resetTimeCount)
				_startTime = currentTime;
		}
		
		public function start():void
		{
			if(_initialStart){
				PBE.processManager.addTickedObject( this );
				_addedToProcessManager = true;
				_initialStart = false;
			}
			_startTime = _ignoreTimeScale ? PBE.processManager.platformTime : PBE.processManager.virtualTime;
			_running = true;
			_activeCount = 0;
			_overallPastTime = 0;
		}
		
		public function stop():void
		{
			//_startTime = PBE.processManager.virtualTime;
			_running = false;
		}
		
		public function get running():Boolean
		{
			return _running;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get ignoreTimeScale():Boolean { return _ignoreTimeScale; }
		public function set ignoreTimeScale(val:Boolean):void
		{
			_ignoreTimeScale = val;
		}

		public function destroy():void
		{
			if(_destroyed)
				return;
			
			_destroyed = true;
			stop();
			onTickSignal.removeAll();
			onTickSignal = null;
			if(_addedToProcessManager){
				PBE.processManager.removeTickedObject( this );
				_addedToProcessManager = false;
			}
		}
	}
}