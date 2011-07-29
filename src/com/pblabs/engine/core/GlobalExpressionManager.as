package com.pblabs.engine.core
{
	import com.pblabs.engine.PBE;

	public final class GlobalExpressionManager implements ITickedObject
	{
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
			var pbeClass : * = PBE;
			var objectContext : Object = PBE.GLOBAL_DYNAMIC_OBJECT;
			//Update mouse position for globally for expressions
			if(!objectContext.Game) objectContext.Game = new Object();
			
			if(!objectContext.Game.Mouse) objectContext.Game.Mouse = new Object();
			objectContext.Game.Mouse.x = PBE.mainStage.mouseX;
			objectContext.Game.Mouse.y = PBE.mainStage.mouseY;

			//Screen Size
			if(!objectContext.Game.Screen) objectContext.Game.Screen = new Object();
			objectContext.Game.Screen.width = PBE.mainStage.stageWidth;
			objectContext.Game.Screen.height = PBE.mainStage.stageHeight;
		}

		private function initialize():void
		{
			
		}
		
	}
}
class Privatizer{}