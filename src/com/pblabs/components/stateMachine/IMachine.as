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
   import com.pblabs.engine.entity.IPropertyBag;

   /**
    * Base interface for a finite state machine.
    */
   public interface IMachine
   {
      /**
       * Update the state machine. The current state is given the opportunity
       * to transition to another state.
       */
      function tick():void;
      
      /**
       * Register a state under a name.
       */
      function addState(name:String, state:IState):void;
      
      /**
       * What state are we on this tick?
       */
      function getCurrentState():IState;
      
      /**
       * What state were we on on the previous tick?
       */
      function getPreviousState():IState;
      
      /**
       * Get the state registered under the provided name.
       */
      function getState(name:String):IState;
      
      /**
       * If this state is registered with us, give back the name it is under.
       */
      function getStateName(state:IState):String;
      
      /**
       * Update the FSM to be in a new state. Current/previous states
       * are updated accordingly, and callbacks and events are dispatched.
       */
      function setCurrentState(name:String):Boolean;

      /**
       * Get the name of the current state.
       */
      function get currentStateName():String;
      
      /**
       * Property bag, if any, related to this state machine.
       */
      function get propertyBag():IPropertyBag;
      function set propertyBag(value:IPropertyBag):void;
   }
}