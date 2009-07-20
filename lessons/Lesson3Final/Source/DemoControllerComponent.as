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
   import PBLabs.Engine.Entity.PropertyReference;

   import flash.geom.Point;

   // Make a ticked component so that it can update itself every frame with OnTick() 
   public class DemoControllerComponent extends TickedComponent
   {
      // Keep a property reference to our entity's position.
      public var PositionReference:PropertyReference;
      
      // Store the direction that our entity is traveling: 1 is to the right, -1 is to the left.
      private var direction:int = 1;   
      
      // OnTick() is called every frame
      public override function OnTick(tickRate:Number):void
      {
         // Copy the owner entity's position into a local Point structure
         var position:Point = Owner.GetProperty(PositionReference);
         
         
         // If we are over the left edge...
         if (position.x < -375) {
            // ...then push ourselves to the right for the time being.
            direction = 1;

            // Move our entity down a notch
            position.y += 20;
         }
         // If we are over the right edge...
         else if (position.x > 375) {
            // ...then push ourselves to the left for the time being.
            direction = -1;
            
            // Move our entity down a notch
            position.y += 20;
         }
         
         // Move 5 units in the direction that we're headed
         position.x += direction * 5;
         
         // Set the spatial component's position based on our new value
         Owner.SetProperty(PositionReference, position);
      }

   }
}