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
      public var registerForTicks:Boolean = true;
      
      /**
       * The update priority for this component. Higher numbered priorities have
       * onInterpolateTick and onTick called before lower priorities.
       */
      public var updatePriority:Number = 0.0;
      
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
      
      override protected function onAdd():void
      {
         if(registerForTicks)
            ProcessManager.instance.addTickedObject(this, updatePriority);
      }
      
      override protected function onRemove():void
      {
         if(registerForTicks)
            ProcessManager.instance.removeTickedObject(this);
      }
   }
}