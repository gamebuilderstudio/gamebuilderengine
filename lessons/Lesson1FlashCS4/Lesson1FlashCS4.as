package
{
	import flash.display.Sprite;
	import com.pblabs.engine.core.Global;
	import com.pblabs.engine.debug.Logger;
	
	public class Lesson1FlashCS4 extends Sprite
	{
		public function Lesson1FlashCS4():void
		{
			Global.startup(this);
			Logger.print(this, "Hello, World!");
		}
	}
}