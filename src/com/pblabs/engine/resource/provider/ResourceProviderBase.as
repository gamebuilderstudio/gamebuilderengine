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
    import com.pblabs.engine.resource.Resource;
    import com.pblabs.engine.resource.ResourceManager;
    import com.pblabs.engine.PBE;

    import flash.utils.Dictionary;
    
    /**
     * The ResourceProviderBase class can be extended to create a ResourceProvider 
     * that will auto register with the ResourceManager
     */
    public class ResourceProviderBase implements IResourceProvider
    {
        public function ResourceProviderBase(registerProvider:Boolean = true)
        {
            // Make sure PBE is initialized - no resource manager, no love.
            if(!PBE.resourceManager)
            {
                throw new Error("Cannot instantiate a ResourceBundle until you have called PBE.startup(this);. Move the call to new YourResourceBundle(); to occur AFTER the call to PBE.startup().");
            }
            
            // register this ResourceProvider with the ResourceManager
            if (registerProvider)
                PBE.resourceManager.registerResourceProvider(this);
            
            // create the Dictionary object that will keep all resources 			
            resources = new Dictionary();
        }
        
        /**
         * This method will check if this provider has access to a specific Resource
         */
        public function isResourceKnown(uri:String, type:Class):Boolean
        {
            var resourceIdentifier:String = uri.toLowerCase() + type;
            return (resources[resourceIdentifier]!=null)
        }
        
        /**
         * This method will request a resource from this ResourceProvider
         */
        public function getResource(uri:String, type:Class, forceReload:Boolean = false):Resource
        {
            var resourceIdentifier:String = uri.toLowerCase() + type;
            return resources[resourceIdentifier];
        }
        
        /**
         * This method will add a resource to the resources Dictionary
         */
        protected function addResource(uri:String, type:Class, resource:Resource):void
        {
            var resourceIdentifier:String = uri.toLowerCase() + type;
            resources[resourceIdentifier] = resource;        	
        }
        
        // ------------------------------------------------------------
        // private and protected variables
        // ------------------------------------------------------------
        protected var resources:Dictionary;
        
    }
}