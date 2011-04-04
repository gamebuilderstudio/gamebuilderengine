package com.flexgangsta.pbtriggers
{
	import com.flexgangsta.pbtriggers.actions.IAction;
	import com.pblabs.engine.entity.EntityComponent;
	
	import flash.events.Event;
	
	public class TriggerComponent extends EntityComponent implements ITriggerComponent
	{
		//______________________________________ 
		//	Component Methods
		//______________________________________
		override protected function onAdd():void
		{
			super.onAdd();
			
			for each(var action:IAction in actions)
			{
				action.owner = this;
			}
			
			//Add Event Handlers
			if(eventType.length)
				this.owner.eventDispatcher.addEventListener(eventType,targetEventHandler);
		}
		
		override protected function onRemove():void
		{
			super.onRemove();
			
			//Remove Event Handlers
			this.owner.eventDispatcher.addEventListener(eventType,targetEventHandler);

			var len : int = actions.length;
			for(var i : int = 0; i < len; i++)
			{
				actions[i].destroy();
			}
			_lastReturn = null;
		}
		
		//______________________________________ 
		//	Public Properties
		//______________________________________	
		public var eventType:String;
		
		[TypeHint(type="com.flexgangsta.pbtriggers.actions.IAction")]
		public function get actions():Array
		{
			return _actions;
		}
		public function set actions(value:Array):void
		{
			_actions = value;
		}
		
		public function get lastReturn():*
		{
			return _lastReturn;
		}
		
		/**
		 * 
		 * The event that was captured by the trigger.
		 * 
		 */		
		public function get event():Event
		{
			return _event;
		}
		
		//______________________________________ 
		//	Public Methods
		//______________________________________
		public function execute():void
		{
			for each(var action:IAction in actions)
			{
				// Early Termination
				if(_exit)
				{
					_exit=false;
					return;
				}
				_lastReturn = action.execute();
			}
		}
		
		//______________________________________ 
		//	Private Properties
		//______________________________________
		private var _exit:Boolean;
		private var _lastReturn:*;
		private var _actions:Array = new Array();
		private var _event:Event;
		
		//______________________________________ 
		//	Private Methods
		//______________________________________
		private function targetEventHandler(event:Event):void
		{
			_event = event;
			execute();
		}
	}
}