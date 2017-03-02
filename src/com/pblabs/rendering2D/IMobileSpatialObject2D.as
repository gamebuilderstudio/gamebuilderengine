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
	   * Pinned getter.
	   */
	  function get pinned():Boolean
	  /**
	   * Pinned setter.
	   */
	  function set pinned(value:Boolean):void;

	  /**
	   * HorizontalPercent getter.
	   */
	  function get horizontalPercent():Number
	  /**
	   * HorizontalPercent setter.
	   */
	  function set horizontalPercent(value:Number):void;

	  /**
	   * horizontalEdge getter.
	   */
	  function get horizontalEdge():String
	  /**
	   * horizontalEdge setter.
	   */
	  function set horizontalEdge(value:String):void;

	  /**
	   * VerticalPercent getter.
	   */
	  function get verticalPercent():Number
	  /**
	   * VerticalPercent setter.
	   */
	  function set verticalPercent(value:Number):void;

	  /**
	   * verticalEdge getter.
	   */
	  function get verticalEdge():String
	  /**
	   * verticalEdge setter.
	   */
	  function set verticalEdge(value:String):void;
	  
	  /**
	   * Position getter.
	   */
	  function get position():Point;
	  
	  /**
	   * Position setter.
	   */
	  function set position(value:Point):void;

	  /**
	   * X Position setter.
	   */
	  function set x(value:Number):void;
	  
	  /**
	   * X Position getter.
	   */
	  function get x():Number;
	  
	  /**
	   * Y Position setter.
	   */
	  function set y(value:Number):void;
	  
	  /**
	   * Y Position getter.
	   */
	  function get y():Number;
	  
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

	  /**
	   * linearVelocity getter.
	   */
	  function get linearVelocity():Point;
	  
	  /**
	   * linearVelocity setter.
	   */
	  function set linearVelocity(value:Point):void;

	  /**
	   * angularVelocity getter.
	   */
	  function get angularVelocity():Number;
	  
	  /**
	   * angularVelocity setter.
	   */
	  function set angularVelocity(value:Number):void;
   }
}
