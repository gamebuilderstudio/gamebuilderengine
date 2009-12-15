package com.pblabs.rendering2D
{
   import flash.geom.Point;
   
   /**
	* Interface that provides mobile spatial information.
   */ 
   public interface IMobileSpatialObject2D extends ISpatialObject2D
   {
	  /**
	   * Position getter.
	   */
	  function get position():Point;
	  
	  /**
	   * Position setter.
	   */
	  function set position(value:Point):void;
	  
	  /**
	   * Rotation getter.
	   */
	  function get rotation():Number;
	  
	  /**
	   * Rotation setter.
	   */
	  function set rotation(value:Number):void;
	  
	  /**
	   * Size getter.
	   */
	  function get size():Point;
	  
	  /**
	   * Size setter.
	   */
	  function set size(value:Point):void;
   }
}
