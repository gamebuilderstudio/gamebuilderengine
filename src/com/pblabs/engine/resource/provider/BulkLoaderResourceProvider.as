package com.pblabs.engine.resource.provider
{
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	
	import com.pblabs.engine.resource.Resource;
	import com.pblabs.engine.resource.XMLResource;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
    /**
     * The BulkLoaderResourceProvider  provides the ResourceManager with resources
     * that are loaded using this provider's BulkLoader instance
     */
	public class BulkLoaderResourceProvider extends ResourceProviderBase
	{
		// -------------------------------------------------------------------
		// public getter/setter property functions
		// -------------------------------------------------------------------
		
        /**
         * Current loading phase
         */
		public function get phase():int
		{
			return _phase;
		}

		// -------------------------------------------------------------------
		// public functions
		// -------------------------------------------------------------------
        /**
         * Constructor
         */
		public function BulkLoaderResourceProvider(name:String, numConnections:int = 12)
		{
			// call ResourceProviderBase constructor to auto-register this provider
			// with the ResourceManager
			super();
									 
			// create this provider's bulk loader object
			loader = new BulkLoader(name, numConnections);
			
			// attach processed and progress events to BulkLoader
			loader.addEventListener(BulkProgressEvent.COMPLETE, resourcesLoaded)
			loader.addEventListener(BulkProgressEvent.PROGRESS, resourcesProgress)			
		}

        /**
        * This method will request a resource from this ResourceProvider
        */
		public override function getResource(uri:String, type:Class, forceReload:Boolean = false):Resource
		{
           	var resourceIdentifier:String = uri.toLowerCase() + type;
			if (forceReload)
			{
				if (loader.get( resourceIdentifier )!=null)
				{
					// let BulkLoader give a notification when this resource has been
					// load so we can initialize it.
				    loader.get(resourceIdentifier).addEventListener(Event.COMPLETE,resourceLoaded)					
					loader.get(resourceIdentifier).addEventListener(BulkLoader.ERROR,resourceError)					
					loader.reload(resourceIdentifier);
					if (!loader.isRunning) loader.start();					
				}				            	 					
			}			
			return resources[resourceIdentifier];
		}

		
        /**
         * Use the function load(onLoaded:Function = null, onProgress:Function = null, onProvideResources:Function = null):void to load resources with the bulk loader
         * 
         * The function onLoaded(phase:int):void will be called when all items of a specific
         * loading phase are loaded by the BulkLoader
         *
         * The function onProgress(phase:int, progress:int):void will be called when current loading phase is progressing
         * progress (0-100)
         *		
         * The function onProvideResources(phase:int):Array will be called for each loading
         * phase, starting with value of 1. The function should return an array with resource objects (Object)
         * each object should have the following attributes
         * 
         * id:String	unique id of item to load 		
         * url:String	url of item to load 
         * type:Class	PBE resource type class
         * 
         * if the onProvideResources function is omitted the overidden function provideResources 
         * will be called on the derived subclass
         * 
       	 * @param onLoaded Function that will called when a phase of loading is completed
       	 * @param onProgress Function that will be called to notify loading progression 
       	 * @param onProvideResources Function that will provide Array with resource objects that have to be loaded
         */
		public function load(onLoaded:Function = null, onProgress:Function = null, onProvideResources:Function = null):void
		{			
			// set event/functions
			this.onLoaded = onLoaded;
			this.onProgress = onProgress;
			
			// if no onProvideResources is provided the overidden provideResources
			// of the derived class will be called to retrieve the resources
			this.onProvideResources = onProvideResources;
		
			// starting phase = 1	
			_phase = 1;
			
			// load resources from first phase
			loadResources();										 			
		}

		// -------------------------------------------------------------------
		// private and protected functions
		// -------------------------------------------------------------------

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
				
        /**
         * override this method to provide resources to be loaded in each phase
         * the function should return an array with resource objects (Object)
         * 
         * each object should have the following attributes
         * 
         * id:String	unique id of item to load 		
         * url:String	url of item to load 
         * type:Class	PBE resource type class
         * 
       	 * @return Array with resource objects
         */
		protected function provideResources():Array
		{	
			return new Array();				
		}
		

        /**
         * This method is called if all resources of a specific phase have been
         * loaded.
         */         
	    private function resourcesLoaded(event:BulkProgressEvent):void
	    {
	    	// Create the Resource Objects and store them so the ResourceManager
	    	// can have access to them
	    	saveResources();
	    	
	    	// call the onloaded event/function if one was provided
	    	if (onLoaded!=null) onLoaded(phase);
	    	
	    	// increment current loading phase
	    	_phase++;
	    	
	    	// load resources from next phase
	    	loadResources();			  
	    } 
	
        /**
         * This method is called while the loading of resources of a specific
         * phase is progressing
         */         
	    private function resourcesProgress(event:BulkProgressEvent):void
	    {
	    	// call the onProgress event/function if one was provided 
	    	if (onProgress!=null) onProgress(phase,Math.round(event.percentLoaded*100));
	    }

        /**
         * This method will request the array with bulkResource Objects of the current
         * phase and will start BulkLoader so the resources will be loaded
         */         
		private function loadResources():void
		{			
 	  		// get array with bulk resources of the current phase 
			if (onProvideResources!=null)
			  	bulkResources = onProvideResources(phase);
			else
				bulkResources = provideResources();
			
			// add the provided resources to BulkLoader
			if (bulkResources && bulkResources.length>0)
			{	
				for (var r:int=0; r<bulkResources.length; r++)
				{
           			var resourceIdentifier:String = bulkResources[r].url.toLowerCase() + bulkResources[r].type;
					if (bulkResources[r].url != "" && bulkResources[r].url != null &&
					    bulkResources[r].type )
					{
						// this object is a valid bulk loader object so add it to BulkLoader
						loader.add(bulkResources[r].url, { id : resourceIdentifier } );				
					}
				}
				
				// start the BulkLoader loading process
				if (!loader.isRunning)
				  loader.start();
			}
		}
		
        /**
         * This method will create the PBE Resource objects of the loaded resources
         * and will save them so that they can be retrieved by the ResourceManager
         */         
		private function saveResources():void
		{
			// register loaded resources with PBE as embedded resources
			for (var r:int=0; r<bulkResources.length; r++)
			{
				if (bulkResources[r].url != "" && bulkResources[r].url != null &&
				    bulkResources[r].type != null )
				{
           			var resourceIdentifier:String = bulkResources[r].url.toLowerCase() + bulkResources[r].type;
					// valid resource so try to get Content from BulkLoader
					if (loader.getContent( resourceIdentifier )!=null)
					{
						// create a new resource of type
						var resource:Resource = new bulkResources[r].type();
						resource.filename = bulkResources[r].url;
												
						// initalize it with the data
						resource.initialize(loader.getContent( resourceIdentifier ));
						// set lookup for later resource retrieval						
						resources[resourceIdentifier] = resource
				 	}
				}				
			}			
		}		
		
		
		// -------------------------------------------------------------------
		// private / protected variables
		// -------------------------------------------------------------------
	    protected var loader:BulkLoader = null;
	    
	    private var _phase:int = 1;
	    private var bulkResources:Array = new Array();

		private var onLoaded:Function = null;
		private var onProgress:Function = null;
		private var onProvideResources:Function = null;

		
	}
}