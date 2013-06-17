package com.pblabs.engine.core
{
	import com.pblabs.engine.PBE;

	public final class GlobalExpressionManager implements ITickedObject
	{
		private var objectContext : Object;
		
		public function GlobalExpressionManager(clazz : Privatizer)
		{
			initialize();
		}
		
		/**
		 * Singleton pattern to retrieve this class
		 **/
		private static var _instance : GlobalExpressionManager;
		public static function get instance():GlobalExpressionManager
		{
			if(!_instance){
				_instance = new GlobalExpressionManager(new Privatizer());
			}
			return _instance
		}

		private var _ignoreTimeScale : Boolean = true;
		/**
		 * @inheritDoc
		 */
		public function get ignoreTimeScale():Boolean { return _ignoreTimeScale; }
		public function set ignoreTimeScale(val:Boolean):void
		{
			_ignoreTimeScale = val;
		}

		public function onTick(deltaTime:Number):void
		{

			//Update mouse position for globally for expressions
			objectContext.Game.Mouse.x = PBE.mainStage.mouseX;
			objectContext.Game.Mouse.y = PBE.mainStage.mouseY;

			for(var i : int = 1; i < 11; i++)
			{
				if(!objectContext.Game["TouchPoint"+i]) 
					objectContext.Game["TouchPoint"+i] = new Object();
				var touchData : InputState = PBE.inputManager.getKeyData(InputKey["TOUCH_"+i].keyCode);
				objectContext.Game["TouchPoint"+i].isTouching = touchData.value;
				objectContext.Game["TouchPoint"+i].x = touchData.stageX;
				objectContext.Game["TouchPoint"+i].y = touchData.stageY;
				objectContext.Game["TouchPoint"+i].pressure = touchData.pressure;
			}

			objectContext.Game.Time.virtualTime = PBE.processManager.virtualTime;
			objectContext.Game.Time.timeScale = PBE.processManager.timeScale;
			objectContext.Game.Time.gameTime = PBE.processManager.platformTime;

			//Screen Size
			objectContext.Game.Screen.width = PBE.mainStage.stageWidth;
			objectContext.Game.Screen.height = PBE.mainStage.stageHeight;

			objectContext.Game.Level.currentLevel = PBE.levelManager.currentLevel;
			objectContext.Game.Level.levelCount = PBE.levelManager.levelCount;
		}

		private function initialize():void
		{
			objectContext = PBE.GLOBAL_DYNAMIC_OBJECT;
			if(!objectContext.Game) objectContext.Game = new Object();
			if(!objectContext.Game.Mouse) objectContext.Game.Mouse = new Object();
			if(!objectContext.Game.Time) objectContext.Game.Time = new Object();
			if(!objectContext.Game.Screen) objectContext.Game.Screen = new Object();
			if(!objectContext.Game.Level) objectContext.Game.Level = new Object();
			objectContext.Game.Level.currentLevel = PBE.levelManager.currentLevel;
		}
	}
}
class Privatizer{}