package com.pblabs.triggers.actions
{
	import com.pblabs.engine.PBE;
	
	public class SimulateInputAction extends BaseAction
	{
		/**
		 * The keycode to simulate
		 **/
		public var keyCode:int;
		/**
		 * Wether to auto simulate the key up on stopping this action
		 **/
		public var autoKeyUp : Boolean = false;

		override public function execute():*
		{
			PBE.inputManager.simulateKeyDown(keyCode);
			return;
		}
		
		override public function stop():void
		{
			if(autoKeyUp)
				PBE.inputManager.simulateKeyUp(keyCode);
		}
	}
}