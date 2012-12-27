package com.pblabs.triggers.actions
{
	import com.pblabs.triggers.ITriggerComponent;

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
		 * Stop the current action. Mostly persistent actions use this to be notified if it needs to stop running.
		 */		
		function stop():void;

		/**
		 * Destroys the current action and performs any cleanup
		 */		
		function destroy():void;

		/**
		 * 
		 * @param value A reference to the trigger that is hosting
		 * the action. 
		 * 
		 */		
		function set owner(value:ITriggerComponent):void;
		function get owner():ITriggerComponent;

		/**
		 * 
		 * @param the custom label for this action, used in the editor 
		 * 
		 */		
		function get label():String;
		function set label(value:String):void;

		/**
		 * Defines whether this action can be run continuously every tick.
		 **/
		function get type():ActionType;
	}
}