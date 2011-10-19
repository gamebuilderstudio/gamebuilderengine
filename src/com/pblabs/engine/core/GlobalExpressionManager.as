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

		public function onTick(deltaTime:Number):void
		{

			//Update mouse position for globally for expressions
			objectContext.Game.Mouse.x = PBE.mainStage.mouseX;
			objectContext.Game.Mouse.y = PBE.mainStage.mouseY;

			objectContext.Game.Time.virtualTime = PBE.processManager.virtualTime;
			objectContext.Game.Time.timeScale = PBE.processManager.timeScale;
			objectContext.Game.Time.gameTime = PBE.processManager.platformTime;

			//Screen Size
			objectContext.Game.Screen.width = PBE.mainStage.stageWidth;
			objectContext.Game.Screen.height = PBE.mainStage.stageHeight;
		}

		private function initialize():void
		{
			objectContext = PBE.GLOBAL_DYNAMIC_OBJECT;
			if(!objectContext.Game) objectContext.Game = new Object();
			if(!objectContext.Game.Mouse) objectContext.Game.Mouse = new Object();
			if(!objectContext.Game.Time) objectContext.Game.Time = new Object();
			if(!objectContext.Game.Screen) objectContext.Game.Screen = new Object();
		}
		
	}
}
class Privatizer{}