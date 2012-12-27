package com.pblabs.triggers.actions
{
	public final class ActionType
	{
		public static const PERSISTANT : ActionType = new ActionType("PERSISTANT");
		public static const ONETIME : ActionType = new ActionType("ONETIME");
		
		private var _name : String = "";
		public function ActionType(name : String)
		{
			_name = name;
		}
		
		public function get name():String{ return _name; }
	}
}