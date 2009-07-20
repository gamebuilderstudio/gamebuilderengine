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
   public class HeroControllerComponent extends TickedComponent
   {
      // Keep a property reference to our entity's position.
      public var PositionReference:PropertyReference;
      
      // OnTick() is called every frame
      public override function OnTick(tickRate:Number):void
      {
      }
   }
}