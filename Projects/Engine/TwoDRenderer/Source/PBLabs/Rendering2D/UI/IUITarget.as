package PBLabs.Rendering2D.UI
{
	import flash.display.*;
	
	/**
	 * Interface a UI element must implement to work with the BaseSceneComponent 
	 * or its subclasses. Deals with adding/removing display objects safely.
	 */
	public interface IUITarget
	{
	  /**
	   * Add a DisplayObject as a child of this control.
	   */ 
      function AddDisplayObject(dobj:DisplayObject):void;
      
      /**
       * Remove all the DisplayObjects that were added by AddDisplayObject.
       */ 
      function ClearDisplayObjects():void;
      
      function get width():Number;
      function get height():Number;
      function get x():Number;
      function get y():Number;
	}
}