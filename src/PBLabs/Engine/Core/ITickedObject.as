/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Engine.Core
{
   /**
    * This interface should be implemented by objects that need to perform
    * actions every tick, such as moving, or processing collision. Performing
    * events every tick instead of every frame will give more consistent and
    * correct results. However, things related to rendering or animation should
    * happen every frame so the visual result appears smooth.
    * 
    * <p>Along with implementing this interface, the object needs to be added
    * to the ProcessManager via the AddTickedObject method.</p>
    * 
    * @see ProcessManager
    * @see IAnimatedObject
    */
   public interface ITickedObject
   {
      /**
       * This method is called every tick by the ProcessManager on any objects
       * that have been added to it with the AddTickedObject method.
       * 
       * @param tickRate The amount of time (in seconds) specified for a tick.
       * 
       * @see ProcessManager#AddTickedObject()
       */
      function OnTick(tickRate:Number):void;
      
      /**
       * This method is called every frame by the ProcessManager on any objects
       * that have been added to it with the AddTickedObject method.
       * 
       * <p>This method should be used to interpolate data between its state
       * on the previous tick and its state on the upcoming tick.</p>
       * 
       * @param factor This is a number between 0 and 1 with 0 representing the
       * previous tick and 1 representing the next tick. In other words, it is
       * the percentage of time between ticks the current frame is.
       * 
       * @see ProcessManager#AddTickedObject()
       */
      function OnInterpolateTick(factor:Number):void;
   }
}