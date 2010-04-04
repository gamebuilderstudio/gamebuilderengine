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
    * Basic, always-on transition.
    */
   public class Transition implements ITransition
   {
      private var _targetState:String;
      
      public function Transition(targetState:String = null)
      {
         _targetState = targetState;
      }
      
      public function evaluate(fsm:IMachine):Boolean
      {
         return true;
      }
      
      public function getTargetState():String
      {
         return _targetState;
      }
      
      public function set targetState(value:String):void
      {
         _targetState = value;
      }
   }
}