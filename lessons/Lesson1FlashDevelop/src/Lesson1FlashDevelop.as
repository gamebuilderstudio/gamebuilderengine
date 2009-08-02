package 
{
	// Flash Imports
	import flash.display.Sprite;
	// PushButton Engine Imports
	import com.pblabs.engine.core.*;
	import com.pblabs.Engine.Debug.*;
	
	public class Lesson1FlashDevelop extends Sprite 
	{
		public function Lesson1FlashDevelop():void 
		{
			Global.startup(this);
			Logger.print(this, "Hello, World!");
		}	
	}	
}