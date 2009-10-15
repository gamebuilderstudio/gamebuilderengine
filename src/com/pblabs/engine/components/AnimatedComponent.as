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
        public var updatePriority:Number = 0.0;

		
		/**
		 * Set to false before onAdd is called to suppress registering for updates. 
		 */
		public var registerForUpdates:Boolean = true;
		
        /**
         * @inheritDoc
         */
        public function onFrame(elapsed:Number):void
        {
        }

        override protected function onAdd():void
        {
			if(registerForUpdates)
            	ProcessManager.instance.addAnimatedObject(this, updatePriority);
        }

        override protected function onRemove():void
        {
			if(registerForUpdates)
            	ProcessManager.instance.removeAnimatedObject(this);
        }
    }
}