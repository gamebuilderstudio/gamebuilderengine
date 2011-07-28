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
			//Update mouse position for globally for expressions
			PBE.GLOBAL_DYNAMIC_OBJECT.Game.Mouse.x = PBE.mainStage.mouseX;
			PBE.GLOBAL_DYNAMIC_OBJECT.Game.Mouse.y = PBE.mainStage.mouseY;

			//Screen Size
			PBE.GLOBAL_DYNAMIC_OBJECT.Game.Screen.width = PBE.mainStage.stageWidth;
			PBE.GLOBAL_DYNAMIC_OBJECT.Game.Screen.height = PBE.mainStage.stageHeight;
		}

		private function initialize():void
		{
			
		}
		
	}
}
class Privatizer{}