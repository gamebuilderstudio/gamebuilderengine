/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.resource.provider
{
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.resource.Resource;
	
	import flash.utils.Dictionary;
	
    /**
     * The EmbeddedResourceProvider provides the ResourceManager with the embedded
     * resources that were loaded from ResourceBundle and ResourceBinding classes
     * 
     * This class works using a singleton pattern so when resource bundles and/or
     * resource bindings are initialized they will register the resources with
     * the EmbeddedResourceProvider.instance
     */
	public class EmbeddedResourceProvider extends ResourceProviderBase
	{
		// ------------------------------------------------------------
		// public getter/setter property functions
		// ------------------------------------------------------------

        /**
         * The singleton instance of the resource manager.
         */
        public static function get instance():EmbeddedResourceProvider
        {
            if (!_instance)
                _instance = new EmbeddedResourceProvider();
            
            return _instance;
        }

		// ------------------------------------------------------------
		// public methods
		// ------------------------------------------------------------

        /**
        * Contructor
        * 
        * Calls the ResourceProvideBase constructor  - super();
        * to auto-register this provider with the ResourceManager
        */
		public function EmbeddedResourceProvider()
		{
			super();
		}        
		
        /**
        * This method is used by the ResourceBundle and ResourceBinding Class to
        * register the existance of a specific embedded resource
        */
		public function registerResource(filename:String, resourceType:Class, data:*):void
        {
        	// create a unique identifier for this resource
            var resourceIdentifier:String = filename.toLowerCase() + resourceType;

			// check if the resource has already been registered            
            if (resources[resourceIdentifier])
            {
                Logger.warn(this, "registerEmbeddedResource", "A resource from file " + filename + " has already been embedded.");
                return;
            }
            
            // Set up the resource
            try
            {
                var resource:Resource = new resourceType();
                resource.filename = filename;
                resource.initialize(data);
                
                // keep the resource in the lookup dictionary                
                resources[resourceIdentifier] = resource;
            }
            catch(e:Error)
            {
                Logger.error(this, "registerEmbeddedResources", "Could not instantiate resource " + filename + " due to error:\n" + e.toString());
                return;
            }
        }
		
		// ------------------------------------------------------------
		// private and protected variables
		// ------------------------------------------------------------		
        private static var _instance:EmbeddedResourceProvider = null;
		
	}
}