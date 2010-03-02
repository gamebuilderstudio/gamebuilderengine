package {
	// Flash Imports
	import flash.display.Sprite;
	
	// PushButton Engine Imports
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.debug.Logger;

	public class Lesson1FlexBuilder extends Sprite
	{
		public function Lesson1FlexBuilder()
		{
			PBE.startup(this);
			Logger.print(this, "Hello, World!");
		}
	}
}
