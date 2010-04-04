/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.components.stateMachine
{
   import flash.events.Event;

    /**
     * Machine fires this event whenever it changes state.
     */
   public class TransitionEvent extends Event
   {
      public static const TRANSITION:String = "fsmStateTransition";
      
      public var oldState:IState;
      public var oldStateName:String;
      public var newState:IState;
      public var newStateName:String;
      
      public function TransitionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
      {
         super(type, bubbles, cancelable);
      }
      
   }
}