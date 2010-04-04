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
   /**
    * Transition interface used by BasicState. Transitions are processed to
    * determine what state to go to next, usually each time their owning state
    * is ticked.
    */
   public interface ITransition
   {
      /**
       * What state will we be transitioning to?
       */
      function getTargetState():String;
      
      /**
       * evaluate the conditions for this state; if true then we go to
       * this transition's target.
       */
      function evaluate(fsm:IMachine):Boolean;
   }
}