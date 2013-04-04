/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2012 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
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
			if(!_modes){
				_modes = new Dictionary();
				_modes[FORWARD.name] = FORWARD;
				_modes[BACKWARD.name] = BACKWARD;
				_modes[FORWARD_LOOP.name] = FORWARD_LOOP;
				_modes[BACKWARD_LOOP.name] = BACKWARD_LOOP;
				_modes[PINGPONG.name] = PINGPONG;
				_modes[RANDOM.name] = RANDOM;
			}
			return _modes[modeName];
		}
	}
}