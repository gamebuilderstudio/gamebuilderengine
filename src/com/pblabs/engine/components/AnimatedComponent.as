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
   import com.pblabs.engine.core.IAnimatedObject;
   import com.pblabs.engine.core.ProcessManager;
   import com.pblabs.engine.entity.EntityComponent;
   
   /**
    * Base class for components that need to perform actions every frame. This
    * needs to be subclassed to be useful.
    */
   public class AnimatedComponent extends EntityComponent implements IAnimatedObject
   {
      /**
       * The update priority for this component. Higher numbered priorities have
       * OnFrame called before lower priorities.
       */
      public var UpdatePriority:Number = 0.0;
      
      /**
       * @inheritDoc
       */
      public function onFrame(elapsed:Number):void
      {
      }
      
      protected override function onAdd():void
      {
         ProcessManager.instance.addAnimatedObject(this, UpdatePriority);
      }
      
      protected override function onRemove():void
      {
         ProcessManager.instance.removeAnimatedObject(this);
      }
   }
}