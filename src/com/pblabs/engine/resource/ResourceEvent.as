/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.resource
{
   import flash.events.Event;
   
   /**
    * A ResourceEvent is an Event used by a Resource to dispatch load status information. In
    * common use, this event never needs to be used as the ResourceManager wraps its
    * functionality.
    * 
    * @see ResourceManager
    * @see Resource 
    */
   public class ResourceEvent extends Event
   {
      /**
       * This event is dispatched by a resource upon successful load of the resource's
       * data.
       * 
       * @eventType LOADED_EVENT
       */
      public static const LOADED_EVENT:String = "LOADED_EVENT";
      
      /**
       * This event is dispatched by a resource when loading of the resource's
       * data fails.
       * 
       * @eventType FAILED_EVENT
       */
      public static const FAILED_EVENT:String = "FAILED_EVENT";
      
      /**
       * The Resource associated with the event.
       */
      public var resourceObject:Resource = null;
      
      public function ResourceEvent(type:String, resource:Resource, bubbles:Boolean=false, cancelable:Boolean=false)
      {
         resourceObject = resource;
         
         super(type, bubbles, cancelable);
      }
   }
}