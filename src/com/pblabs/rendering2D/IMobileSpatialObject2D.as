/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
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
