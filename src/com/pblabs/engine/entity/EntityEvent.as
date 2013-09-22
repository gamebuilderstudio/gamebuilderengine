package com.pblabs.engine.entity
{
	import flash.events.Event;
	
	public final class EntityEvent extends Event
	{
		public static const ON_RESET : String = "ON_RESET";
		
		public function EntityEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}