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
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.components.TickedComponent;
    import com.pblabs.engine.core.InputKey;
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
            // Get references for our spatial position.
            var position:Point = owner.getProperty(positionReference);
            
            // Look at our input keys to see which direction we should move. Left is -x, right is +x.
            if (PBE.isKeyDown(InputKey.RIGHT))
            {
                // Move our hero to the right
                position.x += 15;
            }
            
            if (PBE.isKeyDown(InputKey.LEFT))
            {
                // Move our hero to the left
                position.x -= 15;
            }
            
            // Finally, add some boundary limits so that we don't go off the edge of the screen.
            if (position.x > 375)
            {
                // Set our position at the wall edge
                position.x = 375;               
            } 
            else if (position.x < -375)
            {
                // Set our position at the wall edge
                position.x = -375;
            }
            
            // Send our manipulated spatial variables back to the spatial manager
            owner.setProperty(positionReference, position);
        }    
    }
}