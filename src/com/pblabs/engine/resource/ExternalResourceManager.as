package com.pblabs.engine.resource
{
   import com.pblabs.engine.PBE;
   import com.pblabs.engine.debug.Logger;
   import com.pblabs.engine.resource.ResourceEvent;
   
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   
   /**
    * The external resource manager handles all tasks related to loading external assets SWF files
    * in a project. This includes loading the SWF files, managing its embedded resources, and unloading
    * and cleaning resources in unloaded files.
    */
   public class ExternalResourceManager
   {
      private static var _instance:ExternalResourceManager = null;
      
      public static function get instance():ExternalResourceManager
      {
         if (!_instance)
         {
            _instance = new ExternalResourceManager();
         }
         return _instance;
      }
      
      /**
       * Dictionary of loaded resource files indexed by resource fileName. 
       */
      private var _resources:Dictionary = new Dictionary();
      
      
      /**
       * Dictionary of loaded resources indexed by resource fileName. 
       */
      private var _resourceMap:Dictionary = new Dictionary();
      
      /**
       * Resource file currently being loaded
       */
      private var _currentFileName:String = null;
      
      /**
       * This method is used by the ExternalResourceBundle Class to
       * register the existance of a specific embedded resource and associated to
       * an specific external resources SWF file.
       */
      public function registerResource(resource:Object):void
      {
         if (_resourceMap[_currentFileName] == null)
         {
            _resourceMap[_currentFileName] = new Array();
         }
         _resourceMap[_currentFileName].push(resource);
      }
      
      /**
       * Loads resources from a SWF file. If the resource SWF has already been loaded, a
       * reference to the existing resource will be given. The resource is not returned directly
       * since loading is asynchronous. Instead, it will be passed to the function specified in
       * the onLoaded parameter. Even if the resource has already been loaded, it cannot be
       * assumed that the callback will happen synchronously.
       * 
       * <p>This will not attempt to load resources that have previously failed to load. Instead,
       * the load will fail instantly.</p>
       * 
       * @param filename The url of the file to load.
       * @param resourceType The Resource subclass specifying the type of resource that is being
       * requested.
       * @param onLoaded A function that will be called on successful load of the resource. The
       * function should take a single parameter of the type specified in the resourceType
       * parameter.
       * @param onFailed A function that will be called if loading of the resource fails. The
       * function should take a single parameter of the type specified in the resourceType
       * parameter. The resource passed to the function will be invalid, but the filename
       * property will be correct.
       * @param forceReload Always reload the resource, even if it has already been loaded.
       * 
       * @see Resource
       */
      public function load(filename:String, onLoaded:Function = null, onFailed:Function = null, forceReload:Boolean = false):Object
      {
         // Can only load one resource file at a time
         if (_currentFileName)
         {
            Logger.error(this, "load", "Can only load one asset file at a time.");
            return null;
         }
         
         // Sanity!
         if(filename == null || filename == "")
         {
            Logger.error(this, "load", "Cannot load a resource file with empty filename.");
            return null;
         }
         
         // Look up the resource.
         var resourceIdentifier:String = filename.toLowerCase();
         _currentFileName = resourceIdentifier;
         var externalResource:ExternalResourceFile = _resources[resourceIdentifier];
         
         // If it was loaded and we want to force a reload, do that.
         if (externalResource && forceReload)
         {
            externalResource.unload();
            _resources[resourceIdentifier] = null;
            delete _resources[resourceIdentifier];
            externalResource = null;
         }
         
         // If it wasn't loaded...
         if (!externalResource)
         {
            externalResource = new ExternalResourceFile();
            
            // Store it in the resource dictionary.
            _resources[resourceIdentifier] = externalResource;
            externalResource.load(new URLRequest(filename));
         }
         
         // Deal with it if it already failed, already loaded, or if it is still pending.
         if (externalResource.didFail)
         {
            fail(externalResource, onFailed, "The resource " + filename + " has previously failed to load");
         }
         else if (externalResource.isLoaded)
         {
            if (onLoaded != null)
               PBE.callLater(onLoaded, []);
         }
         else
         {
            // Still in process, so just hook up to its events.
            if (onLoaded != null)
               externalResource.addEventListener(ResourceEvent.LOADED_EVENT, function (event:Event):void { onLoaded(); _currentFileName = null; } );
            
            if (onFailed != null)
               externalResource.addEventListener(ResourceEvent.FAILED_EVENT, function (event:Event):void { onFailed(); _currentFileName = null; } );
         }
         
         return externalResource.loader.contentLoaderInfo;
      }
      
      /**
       * Unloads a previously loaded resource SWF file. This method will force
       * resources to be unloaded even if reference count is not zero.
       * 
       * @param filename The url of the resource SWF file to unload.
       */
      public function unload(filename:String):void
      {
         filename = filename.toLocaleLowerCase();
         
         if (!_resources[filename])
         {
            Logger.warn(this, "Unload", "The resource file " + filename + " is not loaded.");
            return;
         }
         
         // Loop through each external resource associated with this file
         for each(var obj:Object in _resourceMap[filename])
         {
            // Unload using PBE library. The unload function must be changed to allow forced unload.
            PBE.resourceManager.unload(obj.source, obj.resType);
         }
         
         // Clear the resource map
         _resourceMap[filename] = null;
         delete _resourceMap[filename];
         
         // Unload and clear the external SWF file
         _resources[filename].unload();
         _resources[filename] = null;
         delete _resources[filename];
      }
      
      /**
       * Check if a resource is loaded and ready to go. 
       * @param filename Same as request to load()
       * @return True if resource SWF file is loaded.
       */
      public function isLoaded(filename:String):Boolean
      {
         var resourceIdentifier:String = filename.toLowerCase();
         if(!_resources[resourceIdentifier])
            return false;
         
         return (_resources[resourceIdentifier] as ExternalResourceFile).isLoaded;                
      }
      
      /**
       * Properly mark a resource as failed-to-load.
       */
      private function fail(externalResource:ExternalResourceFile, onFailed:Function, message:String):void
      {
         if(!externalResource)
            throw new Error("Tried to fail null resource.");
         
         Logger.error(this, "load", message);
         if (onFailed != null)
            PBE.callLater(onFailed, []);
         
         _currentFileName = null;
      }
   }
}