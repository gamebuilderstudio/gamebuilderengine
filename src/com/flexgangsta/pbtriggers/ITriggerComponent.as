package com.flexgangsta.pbtriggers
{
	import com.pblabs.engine.entity.IEntityComponent;
	
	/**
	 * The main purpose of a trigger is to execute a set group of actions.
	 * It is up to the implementer as to how these actions are exected.
	 * 
	 * @author Jeremy Saenz
	 * 
	 */
	public interface ITriggerComponent extends IEntityComponent
	{
		/**
		 * Contains all of the actions that are to be executed 
		 * 
		 * see com.flexgangsta.pbtriggers.actions.IAction
		 */		
		function get actions():Array;
		function set actions(value:Array):void;
		
		/**
		 * The return object of the last action executed, can be
		 * used tostring actions together via property references. 
		 */		
		function get lastReturn():*;
		
		/**
		 * The return object of the last action executed, can be
		 * used tostring actions together via property references. 
		 */	
		function execute():void;
	}
}