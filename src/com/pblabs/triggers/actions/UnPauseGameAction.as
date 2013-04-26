package com.pblabs.triggers.actions
{
	import com.pblabs.engine.PBE;
	
	public class UnPauseGameAction extends BaseAction
	{
		/**
		 * A toggle to pause all sound that is playing in the engine currently.
		 **/
		public var unPauseSound:Boolean = false;

		override public function execute():*
		{
			PBE.processManager.timeScale = PauseGameAction.previousTimeScale;
			if(unPauseSound)
				PBE.soundManager.volume = PauseGameAction.previousVolume;
			return;
		}
	}
}