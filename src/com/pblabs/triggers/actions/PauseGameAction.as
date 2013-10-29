package com.pblabs.triggers.actions
{
	import com.pblabs.engine.PBE;
	
	public class PauseGameAction extends BaseAction
	{
		public static var previousTimeScale : Number = 1;
		public static var previousVolume : Number = 1;
		/**
		 * A toggle to pause all sound that is playing in the engine currently.
		 **/
		public var pauseSound:Boolean = false;

		override public function execute():*
		{
			var curTimeScale : Number = PBE.processManager.timeScale;
			if(curTimeScale > 0) 
				previousTimeScale = curTimeScale;
			PBE.processManager.timeScale = 0;
			if(pauseSound){
				previousVolume = PBE.soundManager.volume;
				PBE.soundManager.volume = 0;
			}
			return;
		}
	}
}