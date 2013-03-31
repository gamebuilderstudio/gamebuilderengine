package spine.attachments
{
	import flash.utils.Dictionary;

	public final class ModeEnum
	{
		public static const FORWARD : ModeEnum = new ModeEnum("forward");
		public static const BACKWARD : ModeEnum = new ModeEnum("backward");
		public static const FORWARD_LOOP : ModeEnum = new ModeEnum("forwardLoop");
		public static const BACKWARD_LOOP : ModeEnum = new ModeEnum("backwardLoop");
		public static const PINGPONG : ModeEnum = new ModeEnum("pingPong");
		public static const RANDOM : ModeEnum = new ModeEnum("random");
		
		private var _name : String;
		private static var _modes : Dictionary = new Dictionary();
		
		public function ModeEnum(name : String):void
		{
			this._name = name;
			_modes[name] = this;
		}
		
		public function get name():String { return _name; }
		
		public static function getMode(modeName : String) : ModeEnum
		{
			return _modes[modeName];
		}
	}
}