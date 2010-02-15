/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/

package 
{
    import com.pblabs.engine.components.TickedComponent;
    import com.pblabs.engine.entity.PropertyReference;
    
    import flash.geom.Point;
    
    // Make a ticked component so that it can update itself every frame with onTick() 
    public class HeroControllerComponent extends TickedComponent
    {
        // Keep a property reference to our entity's position.
        public var positionReference:PropertyReference;
        
        // onTick() is called every frame
        public override function onTick(tickRate:Number):void
        {
        }
    }
}