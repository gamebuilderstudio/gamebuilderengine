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
    
    /**
     * This interface should be implemented by objects that can provide resources
     * to the resourceManager
     */
    public interface IResourceProvider
    {
        /**
         * This method is called when the ResourceManager gets a load request
         * for a resource and will check all known ResourceProviders if it has
         * the specific resource
         */
        function isResourceKnown(uri:String, type:Class):Boolean;

        /**
         * This method is called when the ResourceManager requests a known
         * resource from a ResourceProvider
         */
        function getResource(uri:String, type:Class, forceReload:Boolean = false):Resource;
    }
}