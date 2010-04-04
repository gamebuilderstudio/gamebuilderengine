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
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	
	import com.pblabs.engine.resource.Resource;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
    /**
     * The LoadedResourceProvider is used by the ResourceManager to request resources
     * that no other resource provider can provide.
     * 
     * A requested resource will be loaded by BulkLoader as it is requested. 
     * 
     * This class works using a singleton pattern
     */
	public class FallbackResourceProvider extends BulkLoaderResourceProvider
	{
		// ------------------------------------------------------------
		// public getter/setter property functions
		// ------------------------------------------------------------

        /**
         * The singleton instance of the resource manager.
         */
        public static function get instance():FallbackResourceProvider
        {
            if (!_instance)
                _instance = new FallbackResourceProvider();
            
            return _instance;
        }
        
		// ------------------------------------------------------------
		// public methods
		// ------------------------------------------------------------
		
        /**
        * Contructor
        */ 
		public function FallbackResourceProvider()
		{
			// call the BulkLoaderResourceProvider parent constructor where we
			// specify that this Provider should not be registered as a normal provider.
			super("PBEFallbackProvider",12,false);
		}
        
        /**
        * This method will check if this provider has access to a specific Resource
        */
		public override function isResourceKnown(uri:String, type:Class):Boolean
		{
			// always return true, because this resource provider will load the 
			// resource on the fly, using BulkLoader when it is requested.
			return true;
		}
				
		// ------------------------------------------------------------
		// private and protected variables
		// ------------------------------------------------------------		
        private static var _instance:FallbackResourceProvider = null;
        
	}
}