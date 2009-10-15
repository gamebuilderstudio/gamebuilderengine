/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.entity
{
   import flash.events.IEventDispatcher;   

   /**
    * Minimal interface for accessing properties on some object.
    */
   public interface IPropertyBag
   {
      /**
       * The event dispatcher that controls events for this entity. Components should
       * use this to dispatch and listen for events.
       */
      function get eventDispatcher():IEventDispatcher;

      /**
       * Checks whether a property exists on this entity.
       * 
       * @param property The property reference describing the property to look for on
       * this entity.
       * 
       * @return True if the property exists, false otherwise.
       */
      function doesPropertyExist(property:PropertyReference):Boolean;
      
      /**
       * Gets the value of a property on this entity.
       * 
       * @param property The property reference describing the property to look for on
       * this entity.
       * @param defaultValue If the property is not found, return this value.
       * 
       * @return The current value of the property, or null if it doesn't exist.
       */
      function getProperty(property:PropertyReference, defaultValue:* = null):*;
      
      /**
       * Sets the value of a property on this entity.
       * 
       * @param property The property reference describing the property to look for on
       * this entity.
       * 
       * @param value The value to set on the specified property.
       */
      function setProperty(property:PropertyReference, value:*):void;      
   }
}