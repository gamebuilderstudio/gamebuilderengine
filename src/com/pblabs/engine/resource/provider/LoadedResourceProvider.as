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
	public class LoadedResourceProvider extends ResourceProviderBase
	{
		// ------------------------------------------------------------
		// public getter/setter property functions
		// ------------------------------------------------------------

        /**
         * The singleton instance of the resource manager.
         */
        public static function get instance():LoadedResourceProvider
        {
            if (!_instance)
                _instance = new LoadedResourceProvider();
            
            return _instance;
        }
        
		// ------------------------------------------------------------
		// public methods
		// ------------------------------------------------------------
		
        /**
        * Contructor
        */ 
		public function LoadedResourceProvider()
		{
			// we will not call super(); because this provider shall not be registered
			// as a normal ResourceManager resource provider
			  
			// create this provider's bulk loader object
			loader = new BulkLoader("loadingProvider");
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
		
        /**
        * This method will request a resource from this ResourceProvider
        */
		public override function getResource(uri:String, type:Class, forceReload:Boolean = false):Resource
		{
            var resourceIdentifier:String = uri.toLowerCase() + type;
            
            // if resource is known return it.
            if (resources[resourceIdentifier]!=null) 
            {
            	if (forceReload)
            	{
					if (loader.get( resourceIdentifier )!=null)
					{
						// let BulkLoader give a notification when this resource has been
						// load so we can initialize it.
						loader.reload(resourceIdentifier);
						if (!loader.isRunning) loader.start();					
					}				            	 					            		
            	}
             	return resources[resourceIdentifier];
            } 
						
			// the resource has to be loaded so add to BulkLoader
			loader.add(uri, { id : resourceIdentifier  } );
			if (!loader.isRunning) loader.start();	

			// let BulkLoader give a notification when this resource has been
			// load so we can initialize it.
			loader.get(resourceIdentifier).addEventListener(Event.COMPLETE,resourceLoaded)
			loader.get(resourceIdentifier).addEventListener(BulkLoader.ERROR,resourceError)
			
			// create resource and provide it to the ResourceManager
			var resource:Resource = new type();
			resource.filename = uri;
			resources[resourceIdentifier] = resource;
			
			return resource;
		}
		// ------------------------------------------------------------
		// private and protected methods
		// ------------------------------------------------------------
		
		private function resourceLoaded(event:Event):void
		{
			// if resource of current LoadingItem exists, initialize it. 			
			if (resources[(event.currentTarget as LoadingItem).id]!=null)
			   (resources[(event.currentTarget as LoadingItem).id] as Resource).initialize(loader.getContent( (event.currentTarget as LoadingItem).id ));
		}		

		private function resourceError(event:ErrorEvent):void
		{
			// if resource of current LoadingItem exists, notify that is has failed 			
			if (resources[(event.currentTarget as LoadingItem).id]!=null)
			{
			   (resources[(event.currentTarget as LoadingItem).id] as Resource).fail(event.text);
			}
		}		
		
		// ------------------------------------------------------------
		// private and protected variables
		// ------------------------------------------------------------		
        private static var _instance:LoadedResourceProvider = null;
	    private var loader:BulkLoader = null;
        
	}
}