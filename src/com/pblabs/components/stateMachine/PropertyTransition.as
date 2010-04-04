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
	import com.pblabs.engine.entity.PropertyReference;
   
   /**
    * Check that a component container property evaluates to some value before 
    * changing state. Expects a Machine FSM.
    */
   public class PropertyTransition extends Transition
   {
      public var property:PropertyReference;
      public var value:String;
      
      override public function evaluate(fsm:IMachine):Boolean
      {
         if(!fsm.propertyBag)
            return false;
         
         return fsm.propertyBag.getProperty(property).toString() == value;
      }
   }
}