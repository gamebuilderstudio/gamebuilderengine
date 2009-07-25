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
   import PBLabs.Engine.Components.TickedComponent;
   import PBLabs.Engine.Core.InputManager;
   import PBLabs.Engine.Core.InputKey;
   import PBLabs.Engine.Entity.PropertyReference;

   import flash.geom.Point;

   // Make a ticked component so that it can update itself every frame with OnTick() 
   public class HeroControllerComponent extends TickedComponent
   {
      // Keep a property reference to our entity's position.
      public var PositionReference:PropertyReference;

      // OnTick() is called every frame
      public override function OnTick(tickRate:Number):void
      {
         // Get references for our spatial position.
         var position:Point = Owner.GetProperty(PositionReference);

         // Look at our input keys to see which direction we should move. Left is -x, right is +x.
         if (InputManager.IsKeyDown(InputKey.RIGHT))
         {
            // Move our hero to the right
            position.x += 15;
         }
         if (InputManager.IsKeyDown(InputKey.LEFT))
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
         Owner.SetProperty(PositionReference, position);
      }    
   }
}