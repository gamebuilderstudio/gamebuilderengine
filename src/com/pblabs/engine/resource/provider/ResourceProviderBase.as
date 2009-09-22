package com.pblabs.engine.resource.provider
{
	import com.pblabs.engine.resource.Resource;
	import com.pblabs.engine.resource.ResourceManager;
	
	import flash.utils.Dictionary;
	
    /**
     * The ResourceProviderBase class can be extended to create a ResourceProvider 
     * that will auto register with the ResourceManager
     */
	public class ResourceProviderBase implements IResourceProvider
	{
		public function ResourceProviderBase()
		{
			// register this ResourceProvider with the ResourceManager
			ResourceManager.instance.registerResourceProvider(this);			
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

		// ------------------------------------------------------------
		// private and protected variables
		// ------------------------------------------------------------
        protected var resources:Dictionary = new Dictionary();
		
	}
}