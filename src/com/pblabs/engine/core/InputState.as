package com.pblabs.engine.core
{
	public final class InputState
	{
		public var preventDefaultBehaviour : Boolean = false;
		public var value : Boolean = false;
		public var keyCode : int = -1;
		public var stageX : Number;
		public var stageY : Number;
		public var pressure : Number;
		public var touchCount : int = 0;
		public var phase : String = "";
		public var id : int = -1;
		
		private static var _pool : Vector.<InputState> = new Vector.<InputState>();
		
		public function InputState(keyCode : int):void
		{
			this.keyCode = keyCode;
		}
		public static function getInstance(keyCode : int):InputState
		{
			if(_pool.length < 1)
				return new InputState(keyCode);
			return _pool.shift();
		}
		
		public function dispose():void
		{
			preventDefaultBehaviour = false;
			value = false;
			keyCode = -1;
			touchCount = 0;
			stageX = stageY = 0;
			pressure = 0;
			phase = "";
			id = -1;
			if(_pool.indexOf(this) == -1)
				_pool.push(this);
		}
	}
}