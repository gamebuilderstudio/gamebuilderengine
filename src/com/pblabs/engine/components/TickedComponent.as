/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.components
{
   import com.pblabs.engine.core.ITickedObject;
   import com.pblabs.engine.core.ProcessManager;
   import com.pblabs.engine.entity.EntityComponent;
   
   /**
    * Base class for components that need to perform actions every tick. This
    * needs to be subclassed to be useful.
    */
   public class TickedComponent extends EntityComponent implements ITickedObject
   {
      /**
       * Do we actually want to register for ticks? Useful if a subclass wants
       * to disable the functionality. Only checked at onAdd/onRemove time.
       */
      [EditorData(DefaultValue="true")]
      public var RegisterForTicks:Boolean = true;
      
      /**
       * The update priority for this component. Higher numbered priorities have
       * OnInterpolateTick and OnTick called before lower priorities.
       */
      public var UpdatePriority:Number = 0.0;
      
      /**
       * @inheritDoc
       */
      public function onTick(tickRate:Number):void
      {
      }
      
      /**
       * @inheritDoc
       */
      public function onInterpolateTick(factor:Number):void
      {
      }
      
      protected override function onAdd():void
      {
         if(RegisterForTicks)
            ProcessManager.instance.addTickedObject(this, UpdatePriority);
      }
      
      protected override function onRemove():void
      {
         if(RegisterForTicks)
            ProcessManager.instance.removeTickedObject(this);
      }
   }
}