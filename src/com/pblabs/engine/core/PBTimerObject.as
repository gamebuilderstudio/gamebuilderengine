package com.pblabs.engine.core
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.core.ITickedObject;
	import com.pblabs.engine.debug.Logger;
	
	import org.osflash.signals.Signal;
	
	public final class PBTimerObject implements ITickedObject
	{
		public var onTickSignal : Signal = new Signal();
		public var delay : Number = 0;
		public var repeatCount : int = 0;
		public var limit : Number = 0;
		
		private var _initialStart : Boolean = true;
		private var _startTime : Number = 0;
		private var _running : Boolean = false;
		private var _activeCount : int = 0;
		private var _activePastTime : Number = 0;
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
				if(delay == 0 || delay < 0){
					if(delay == 0 && limit > 0)
					{
						_overallPastTime = _currentTime - _startTime;
						if(_overallPastTime >= limit)
						{
							onTickSignal.dispatch();
							stop();
						}
					}else{
						onTickSignal.dispatch();
						_activeCount++;
					}
				}else{
					_activePastTime = _currentTime - _startTime;
					if(delay <= _activePastTime)
					{
						onTickSignal.dispatch();
						_activeCount++;
						_startTime = _currentTime;
					}
				}
			}
		}
		public function start():void
		{
			if(_initialStart){
				PBE.processManager.addTickedObject( this );
				_addedToProcessManager = true;
				_initialStart = false;
			}
			_startTime = PBE.processManager.virtualTime;
			_running = true;
			_activeCount = 0;
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
			if(_addedToProcessManager){
				PBE.processManager.removeTickedObject( this );
				_addedToProcessManager = false;
			}
			onTickSignal.removeAll();
			onTickSignal = null;
		}
	}
}