package 
{
	// Flash Imports
	import flash.display.Sprite;
	// PushButton Engine Imports
	import com.pblabs.engine.core.Global;
	import com.pblabs.engine.debug.Logger;
	
	public class Lesson1FlashDevelop extends Sprite 
	{
		public function Lesson1FlashDevelop():void 
		{
			Global.startup(this);
			Logger.print(this, "Hello, World!");
		}	
	}	
}