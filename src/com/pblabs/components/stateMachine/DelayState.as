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
    * State that enforces a delay (measured in ticks) before attempting
    * to transition.
    */
   public class DelayState extends BasicState
   {
      /**
       * Number of ticks to wait before switching state.
       * 
       * If this is 2, then on the second Tick() we will change state.
       */
      public var delay:Number = 0;
      
      /**
       * Variance in duration of delay. Plus or minus.
       */
      public var variance:Number = 0;
      
      /**
       * Number of ticks remaining.
       */
      public var delayRemaining:int = 0;
            
      override public function enter(fsm:IMachine):void
      {
         // Set the delay.
         delayRemaining = delay;
         
         if(variance > 0)
            delayRemaining += Math.round(2.0 * (Math.random() - 0.5) * variance);
         
         // Pass control up.
         super.enter(fsm);
      }
      
      override public function tick(fsm:IMachine):void
      {
         // Tick the delay.
         //trace("Ticking delay state!");
         delayRemaining--;
         if(delayRemaining > 0)
            return;
            
         // Pass control upwards.
         super.tick(fsm);   
      }
   }
}