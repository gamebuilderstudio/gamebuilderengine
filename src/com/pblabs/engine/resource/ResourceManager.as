/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.resource
{
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.PBUtil;
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.engine.resource.provider.EmbeddedResourceProvider;
    import com.pblabs.engine.resource.provider.FallbackResourceProvider;
    import com.pblabs.engine.resource.provider.IResourceProvider;
    import com.pblabs.engine.serialization.TypeUtility;
    
    import flash.events.Event;
    import flash.utils.Dictionary;
    
    /**
     * The resource manager handles all tasks related to using asset files (images, xml, etc)
     * in a project. This includes loading files, managing embedded resources, and cleaninp up
     * resources no longer in use.
     */
    public class ResourceManager
    {        
        /**
         * If true, we will never get resources from outside the SWF - only resources
         * that have been properly embedded and registered with the ResourceManager
         * will be used.
         */
        public var onlyLoadEmbeddedResources:Boolean = false;
        
        /**
         * Function that will be called if OnlyLoadEmbeddedResources is set and we
         * fail to find something. Useful for displaying feedback for artists (such
         * as via a dialog box ;). Passed the filename of the requested resource.
         */
        public var onEmbeddedFail:Function;
        
        /**
         * Loads a resource from a file. If the resource has already been loaded or is embedded, a
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
        public function load(filename:String, resourceType:Class, onLoaded:Function = null, onFailed:Function = null, forceReload:Boolean = false):Resource
        {
            // Sanity!
            if(filename == null || filename == "")
            {
                Logger.error(this, "load", "Cannot load a " + resourceType + " with empty filename.");
                return null;
            }
            
            // Look up the resource.
            var resourceIdentifier:String = filename.toLowerCase() + resourceType;
            var resource:Resource = _resources[resourceIdentifier];
            
            // If it was loaded and we want to force a reload, do that.
            if (resource && forceReload)
            {
                _resources[resourceIdentifier] = null;
                delete _resources[resourceIdentifier];
                resource = null;
            }
            
            // If it wasn't loaded...
            if (!resource)
            {
                // Then it wasn't embedded, so error if we're configured for that. 
                if(onlyLoadEmbeddedResources && !EmbeddedResourceProvider.instance.isResourceKnown(filename, resourceType))
                {
                    var tmpR:Resource = new Resource();
                    tmpR.filename = filename;
                    tmpR.fail("not embedded in the SWF with type " + resourceType + ".");
                    fail(tmpR, onFailed, "'" + filename + "' was not loaded because it was not embedded in the SWF with type " + resourceType + ".");
                    if(onEmbeddedFail != null)
                        onEmbeddedFail(filename);
                    return null;
                }
                
                // Hack for MP3 and WAV files. TODO: Generalize this for arbitrary formats.
                var fileExtension:String = PBUtil.getFileExtension(filename).toLocaleLowerCase();
                if(resourceType == SoundResource && (fileExtension == "mp3" || fileExtension == "wav"))
                    resourceType = MP3Resource;
                
                // check available resource providers and request the resource if it is known
                for (var rp:int = 0; rp < resourceProviders.length; rp++)
                {
                    if ((resourceProviders[rp] as IResourceProvider).isResourceKnown(filename, resourceType))
                        resource  = (resourceProviders[rp] as IResourceProvider).getResource(filename, resourceType, forceReload);
                }
                
                // If we couldn't find a match, fall back to the default provider.
                if (!resource)
                    resource = FallbackResourceProvider.instance.getResource(filename, resourceType, forceReload);
                
                // Make sure the filename is set.
                if(!resource.filename)
                    resource.filename = filename;
                
                // Store it in the resource dictionary.
                _resources[resourceIdentifier] = resource;
            }
            else if (!(resource is resourceType))
            {
                fail(resource, onFailed, "The resource " + filename + " is already loaded, but is of type " + TypeUtility.getObjectClassName(resource) + " rather than the specified " + resourceType + ".");
                return null;
            }
            
            // Deal with it if it already failed, already loaded, or if it is still pending.
            if (resource.didFail)
            {
                fail(resource, onFailed, "The resource " + filename + " has previously failed to load");
            }
            else if (resource.isLoaded)
            {
                if (onLoaded != null)
                    PBE.callLater(onLoaded, [ resource ]);
            }
            else
            {
                // Still in process, so just hook up to its events.
                if (onLoaded != null)
                    resource.addEventListener(ResourceEvent.LOADED_EVENT, function (event:Event):void { onLoaded(resource); } );
                
                if (onFailed != null)
                    resource.addEventListener(ResourceEvent.FAILED_EVENT, function (event:Event):void { onFailed(resource); } );
            }
            
            // Don't forget to bump its ref count.
            resource.incrementReferenceCount();
            
            return resource;
        }
        
        /**
         * Unloads a previously loaded resource. This does not necessarily mean the resource
         * will be available for garbage collection. Resources are reference counted so if
         * the specified resource has been loaded multiple times, its reference count will
         * only decrease as a result of this.
         * 
         * @param filename The url of the resource to unload.
         * @param resourceType The type of the resource to unload.
         */
        public function unload(filename:String, resourceType:Class):void
        {
            // Right now unload is unloading embedded resources inappropriately. Since
            // they are going to be in memory anyway as part of the SWF, I am disabling
            // Unload for now.
            
            // mas : we probably have to unload the resource @ the specific resourceProvider
            // 		 as well! so we have to take this into account when we reactivate the
            //		 unload.
            
            return;
            
            if (!_resources[filename + resourceType])
            {
                Logger.warn(this, "Unload", "The resource from file " + filename + " of type " + resourceType + " is not loaded.");
                return;
            }
            
            _resources[filename + resourceType].DecrementReferenceCount();
            if (_resources[filename + resourceType].ReferenceCount < 1)
            {
                _resources[filename + resourceType] = null;
                delete _resources[filename + resourceType];
            }
        }
        
        /**
         * Registers data with the resource manager to be treated as a resource. This is
         * used by embedded resources, which is facilitated by the ResourceBinding class.
         * 
         * @param filename The name to register the resource under. In the case of embedded
         * resources, it should match the filename of the resource.
         * @param resourceType The Resource subclass to create with the specified data.
         * @param data A byte array containing the data for the resource. This should match
         * up with the data expected by the specific Resource subclass.
         * 
         * @see com.pblabs.engine.resource.ResourceBundle
         */
        public function registerEmbeddedResource(filename:String, resourceType:Class, data:*):void
        {
            var resourceIdentifier:String = filename.toLowerCase() + resourceType;
            
            if (_resources[resourceIdentifier])
            {
                Logger.warn(this, "registerEmbeddedResource", "A resource from file " + filename + " has already been embedded.");
                return;
            }
            
            try
            {
                // Set up the resource, but don't process it yet.
                var resource:Resource = new resourceType();
                resource.filename = filename;
                resource.initialize(data);
                
                // These can be in the try since the catch will return.
                resource.incrementReferenceCount();
                _resources[resourceIdentifier] = resource;
            }
            catch(e:Error)
            {
                Logger.error(this, "registerEmbeddedResources", "Could not instantiate resource " + filename + " due to error:\n" + e.toString());
                return;
            }
        }
        
        /**
         * Provide a source for resources to the ResourceManager. Once added,
         * the ResourceManager will use this IResourceProvider to try to fulfill
         * resource load requests.
         *  
         * @param resourceProvider Provider to add.
         * @see IResourceProvider
         */
        public function registerResourceProvider(resourceProvider:IResourceProvider):void
        {
            // check if resourceProvider is already registered
            if (resourceProviders.indexOf(resourceProvider) != -1)
            {
                Logger.warn(ResourceManager, "registerResourceProvider", "Tried to register ResourceProvider '" + resourceProvider + "' twice. Ignoring...");
                return;
            }
            
            // add resourceProvider to list of known resourceProviders
            resourceProviders.push(resourceProvider);
        }
        
        /**
         * Check if a resource is loaded and ready to go. 
         * @param filename Same as request to load()
         * @param type Same as request to load().
         * @return True if resource is loaded.
         */
        public function isLoaded(filename:String, resourceType:Class):Boolean
        {
            var resourceIdentifier:String = filename.toLowerCase() + resourceType;
            if(!_resources[resourceIdentifier])
                return false;
            
            var r:Resource = _resources[resourceIdentifier];
            return r.isLoaded;                
        }
        
        /**
         * Properly mark a resource as failed-to-load.
         */
        private function fail(resource:Resource, onFailed:Function, message:String):void
        {
            if(!resource)
                throw new Error("Tried to fail null resource.");
            
            Logger.error(this, "load", message);
            if (onFailed != null)
                PBE.callLater(onFailed, [resource]);
        }
        
        /**
         * Dictionary of loaded resources indexed by resource name and type. 
         */
        private var _resources:Dictionary = new Dictionary();
        
        /**
         * List of resource providers used to get resources. 
         */        
        private var resourceProviders:Array = new Array();
    }
}
