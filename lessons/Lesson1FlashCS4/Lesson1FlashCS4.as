package
{
	import flash.display.Sprite;
    
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.debug.Logger;
	
	public class Lesson1FlashCS4 extends Sprite
	{
		public function Lesson1FlashCS4():void
		{
			PBE.startup(this);
			Logger.print(this, "Hello, World!");
		}
	}
}