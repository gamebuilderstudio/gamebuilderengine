package com.flexgangsta.pbtriggers.actions
{
	import com.flexgangsta.pbtriggers.ITriggerComponent;

	/**
	 * The main purpose of a trigger is to execute a set group of actions.
	 * Actions are simply classes that fulfill a single purpose of executing
	 * code when the <code>execute</code> function is called by the trigger.
	 * 
	 * @author Jeremy Saenz
	 * 
	 */	
	public interface IAction
	{
		/**
		 * Executes the task that the action is set to perform.
		 * 
		 * @return The object that will be assigned to the owning
		 * trigger's <code>lastReturn</code> property.
		 * 
		 */		
		function execute():*;
		
		/**
		 * Destorys the current action and performs any cleanup
		 */		
		function destroy():void;

		/**
		 * 
		 * @param value A reference to the trigger that is hosting
		 * the action. 
		 * 
		 */		
		function set owner(value:ITriggerComponent):void;
	}
}