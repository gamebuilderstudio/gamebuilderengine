package 
{
	// Flash Imports
	import flash.display.Sprite;
    
	// PushButton Engine Imports
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.debug.Logger;
	
	public class Lesson1FlashDevelop extends Sprite 
	{
		public function Lesson1FlashDevelop():void 
		{
			PBE.startup(this);
			Logger.print(this, "Hello, World!");
		}	
	}	
}