/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Engine.Components
{
   import PBLabs.Engine.Core.ITickedObject;
   import PBLabs.Engine.Core.ProcessManager;
   import PBLabs.Engine.Entity.EntityComponent;
   
   /**
    * Base class for components that need to perform actions every tick. This
    * needs to be subclassed to be useful.
    */
   public class TickedComponent extends EntityComponent implements ITickedObject
   {
      /**
       * Do we actually want to register for ticks? Useful if a subclass wants
       * to disable the functionality. Only checked at _OnAdd/_OnRemove time.
       */       
      public var RegisterForTicks:Boolean = true;
      
      /**
       * The update priority for this component. Higher numbered priorities have
       * OnInterpolateTick and OnTick called before lower priorities.
       */
      public var UpdatePriority:Number = 0.0;
      
      /**
       * @inheritDoc
       */
      public function OnTick(tickRate:Number):void
      {
      }
      
      /**
       * @inheritDoc
       */
      public function OnInterpolateTick(factor:Number):void
      {
      }
      
      protected override function _OnAdd():void
      {
         if(RegisterForTicks)
            ProcessManager.Instance.AddTickedObject(this, UpdatePriority);
      }
      
      protected override function _OnRemove():void
      {
         if(RegisterForTicks)
            ProcessManager.Instance.RemoveTickedObject(this);
      }
   }
}