package com.pblabs.triggers.actions
{
	import com.pblabs.screens.ScreenManager;

	public class ChangeScreenAction extends BaseAction
	{
		
		public static const OVERLAY_SCREEN : String = "overlay";
		public static const GOTO_SCREEN : String = "goto";

		/**
		 * The screen to load
		 **/
		public var screenName : String;
		/**
		 * The uid of the screen to load
		 **/
		public var screenId : String;
		/**
		 * The method used to show the screen
		 **/
		public var loadType : String = OVERLAY_SCREEN;
		/**
		 * Transition effect
		 **/
		public var transitionEffect : String;
		
		public function ChangeScreenAction(){
			super();
		}
		
		override public function execute():*
		{
			if(screenId)
				var gamesScreenName : String = String("screen_"+(screenId.split("-").join("_")));
			if(!screenName || !screenId || !ScreenManager.instance.hasScreen(gamesScreenName) || ScreenManager.instance.getCurrentScreenName() == gamesScreenName)
				return;
			
			switch(loadType)
			{
				case OVERLAY_SCREEN:
					ScreenManager.instance.push( gamesScreenName );
					break;
				case GOTO_SCREEN:
					ScreenManager.instance.moveto( gamesScreenName );
					break;
			}
		}
		
		override public function destroy():void
		{
			super.destroy();
		}
	}
}