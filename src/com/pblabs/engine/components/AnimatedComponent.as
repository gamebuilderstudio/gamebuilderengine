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
    import com.pblabs.engine.PBE;
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
        [EditorData(ignore="true")]
        public var updatePriority:Number = 0.0;
        
        private var _registerForUpdates:Boolean = true;
        private var _isRegisteredForUpdates:Boolean = false;
		private var initialRegisterForUpdates:Boolean = true;
        
        /**
         * Set to register/unregister for frame updates.
         */
        [EditorData(ignore="true")]
        public function set registerForUpdates(value:Boolean):void
        {
            _registerForUpdates = value;
            
            if(_registerForUpdates && !_isRegisteredForUpdates)
            {
                // Need to register.
                _isRegisteredForUpdates = true;
                PBE.processManager.addAnimatedObject(this, updatePriority);
            }
            else if(!_registerForUpdates && _isRegisteredForUpdates)
            {
                // Need to unregister.
                _isRegisteredForUpdates = false;
                PBE.processManager.removeAnimatedObject(this);
            }
        }
        
        /**
         * @private
         */
        public function get registerForUpdates():Boolean
        {
            return _registerForUpdates;
        }
        
        /**
         * @inheritDoc
         */
        public function onFrame(deltaTime:Number):void
        {
        }
        
        override protected function onAdd():void
        {
			// keep initial _registerFoUpdates value so we can reset this if the component to its 
			// initial state after it is removed and before it is added again to an entity.
			initialRegisterForUpdates = _registerForUpdates;
			// registerForTicks could be set to a specific value(false) using XML
			// so by setting it so its own value we will actually register if we weren't already.
            registerForUpdates = registerForUpdates;
        }
        
        override protected function onRemove():void
        {
            // Make sure we are unregistered.
            registerForUpdates = false;
			// reset _registerForUpdates value so we got a healthy initial condition when we  
			// add this component to an entity again.
			_registerForUpdates = initialRegisterForUpdates; 
        }
    }
}