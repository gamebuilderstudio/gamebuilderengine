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
   import com.pblabs.engine.entity.IEntity;

   /**
   * State which destroys its owning container when it is entered.
   */
   public class DeathState extends BasicState
   {
      override public function enter(fsm:IMachine):void
      {
         // Kill ourselves!
         var entity:IEntity = fsm.propertyBag as IEntity;
         if(!entity)
            throw new Error("Cannot call Destroy on a non-entity!");
         entity.destroy();
      }
   }
}