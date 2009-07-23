package 
{
	// Flash Imports
	import flash.display.Sprite;
	// PushButton Engine Imports
	import PBLabs.Engine.Core.*;
	import PBLabs.Engine.Debug.*;
	
	public class Lesson1FlashDevelop extends Sprite 
	{
		public function Lesson1FlashDevelop():void 
		{
			Global.Startup(this);
			Logger.Print(this, "Hello, World!");
		}	
	}	
}