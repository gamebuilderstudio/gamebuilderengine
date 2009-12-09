package com.pblabs.rendering2D.ui
{
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;

	/**
	 * Interface a UI element must implement to work with the BaseSceneComponent 
	 * or its subclasses. Deals with adding/removing display objects safely.
	 */
	public interface IUITarget extends IEventDispatcher
	{
	  /**
	   * Add a DisplayObject as a child of this control.
	   */ 
      function addDisplayObject(dobj:DisplayObject):void;
      
      /**
       * Remove all the DisplayObjects that were added by AddDisplayObject.
       */ 
      function clearDisplayObjects():void;
      
      /**
       * Remove a display object as a child of this control. 
       * @param dobj Display object to remove.
       */
      function removeDisplayObject(dobj:DisplayObject):void;
      
      /**
       * Set the index of a display object which is added to this control.
       * @param dobj Object to position in order.
       * @param index Draw order to assign.
       */
      function setDisplayObjectIndex(dobj:DisplayObject, index:int):void;
      
      function get width():Number;
      function set width(value:Number):void;
      function get height():Number;
      function set height(value:Number):void;
      function get x():Number;
      function get y():Number;
	}
}