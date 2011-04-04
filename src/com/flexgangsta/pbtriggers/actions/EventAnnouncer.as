package com.flexgangsta.pbtriggers.actions
{
	import com.flexgangsta.pbtriggers.ITriggerComponent;
	import com.pblabs.engine.debug.Logger;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class EventAnnouncer implements IAction
	{
		//______________________________________ 
		//	Public Properties
		//______________________________________
		public var properties:Dictionary = new Dictionary();
		
		public var eventType:String;
		
		public function set definition(value:String):void
		{
			try 
			{
				EventClass = getDefinitionByName(value) as Class;
				
			}
			catch(e:Error)
			{
				Logger.error(this,"set definition","Class definition " + value + " does not exist, the event dispatched will be the default: flash.events.Event");
			}
		}
		
		public function set owner(value:ITriggerComponent):void
		{
			_owner = value;
		}
		
		//______________________________________ 
		//	Public Methods
		//______________________________________
		public function execute():*
		{
			// Generate Event
			var event:Event = new EventClass(eventType);
			
			for (var key:String in properties)
			{
				try
				{
					event[key] = properties[key];
				}
				catch(e:Error)
				{
					Logger.error(this,"execute","Property " + key + " does not exist on event of type " + getQualifiedClassName(EventClass));
				}
			}
			
			//Dispatch Event
			_owner.owner.eventDispatcher.dispatchEvent(event);
			return event;
		}
		
		public function destroy():void
		{
			for (var key:String in properties)
			{
				delete properties[key];
			}
			_owner = null;
		}
		//______________________________________ 
		//	Private Properties
		//______________________________________
		private var _owner:ITriggerComponent;
		private var EventClass:Class = getDefinitionByName("flash.events.Event") as Class;
	}
}