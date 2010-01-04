/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.components.basic
{
    import com.pblabs.engine.entity.IEntity;
    
    import flash.events.Event;
    
    
    /**
     * Event fired by the HealthComponent on the entity when health changes.
     */
    public class HealthEvent extends Event
    {
        /**
         * Change in health.
         */
        public var delta:Number;
        
        /**
         * Current health amount, after the delta. The health property on the 
         * component is not updated until after the event is processed.
         */
        public var amount:Number;
        
        /**
         * Entity which caused this damage (or healing), if any.
         */
        public var originatingEntity:IEntity;
        
        public function HealthEvent(type:String, deltaAmt:Number, amountAmt:Number, originator:IEntity, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            delta = deltaAmt;
            amount = amountAmt;
            originatingEntity = originator;
            super(type, bubbles, cancelable);
        }
        
        public function isDead():Boolean
        {
            return amount == 0;
        }
    }
}