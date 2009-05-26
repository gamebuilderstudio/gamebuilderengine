/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Engine.Resource
{
   import PBLabs.Engine.Debug.Logger;
   import PBLabs.Engine.Serialization.TypeUtility;
   
   import flash.events.Event;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.setTimeout;

   /**
    * The resource manager handles all tasks related to using asset files (images, xml, etc)
    * in a project. This includes loading files, managing embedded resources, and cleaninp up
    * resources no longer in use.
    * 
    * @see ../../../../../Reference/ResourceManager.html The Resource Manager
    * @see ../../../../../Examples/UsingResources.html Using Resources
    */
   public class ResourceManager
   {
      /**
       * The singleton instance of the resource manager.
       */
      public static function get Instance():ResourceManager
      {
         if (_instance == null)
            _instance = new ResourceManager();
         
         return _instance;
      }
      
      private static var _instance:ResourceManager = null;
      
      /**
       * If true, we will never get resources from outside the SWF - only resources
       * that have been properly embedded and registered with the ResourceManager
       * will be used.
       */
      public var OnlyLoadEmbeddedResources:Boolean = false;
      
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
       * parameter. The resource passed to the function will be invalid, but the Filename
       * property will be correct.
       * @param forceReload Always reload the resource, even if it has already been loaded.
       * 
       * @see Resource
       */
      public function Load(filename:String, resourceType:Class, onLoaded:Function = null, onFailed:Function = null, forceReload:Boolean = false):void
      {
         var resource:Resource = _resources[filename + resourceType];

         if ((resource != null) && forceReload)
         {
            _resources[filename + resourceType] = null;
            delete _resources[filename + resourceType];
            resource = null;
         }
         
         if (resource == null)
         {
            if(OnlyLoadEmbeddedResources)
            {
               _Fail(null, onFailed, "'" + filename + "' was not loaded because it was not embedded in the SWF.");
               return;
            }
            
            var testResource:* = new resourceType();
            if (!(testResource is Resource))
            {
               _Fail(null, onFailed, "Failed to load resource from file " + filename + ". The specified resource type " + resourceType + " is not a Resource subclass.");
               return;
            }
            
            resource = testResource;
            resource.Load(filename);
            _resources[filename + resourceType] = resource;
         }
         else if (!(resource is resourceType))
         {
            _Fail(resource, onFailed, "The resource " + filename + " is already loaded, but is of type " + TypeUtility.GetObjectClassName(resource) + " rather than the specified " + resourceType + ".");
            return;
         }
         
         if (resource.DidFail)
         {
            _Fail(resource, onFailed, "The resource " + filename + " has previously failed to load");
         }
         else if (resource.IsLoaded)
         {
            if (onLoaded != null)
               setTimeout(onLoaded, 1, resource);
         }
         else
         {
            if (onLoaded != null)
               resource.addEventListener(ResourceEvent.LOADED_EVENT, function (event:Event):void { onLoaded(resource); } );
            
            if (onFailed != null)
               resource.addEventListener(ResourceEvent.FAILED_EVENT, function (event:Event):void { onFailed(resource); } );
         }
         
         resource.IncrementReferenceCount();
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
      public function Unload(filename:String, resourceType:Class):void
      {
         // Right now unload is unloading embedded resources inappropriately. Since
         // they are going to be in memory anyway as part of the SWF, I am disabling
         // Unload for now.
         return;
         
         if (_resources[filename + resourceType] == null)
         {
            Logger.PrintWarning(this, "Unload", "The resource from file " + filename + " of type " + resourceType + " is not loaded.");
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
       * @see PBLabs.Engine.MXML.ResourceBinding
       */
      public function RegisterEmbeddedResource(filename:String, resourceType:Class, data:ByteArray):void
      {
         if (_resources[filename + resourceType] != null)
         {
            Logger.PrintWarning(this, "RegisterEmbeddedResource", "A resource from file " + filename + " has already been embedded.");
            return;
         }
         
         // Set up the resource, but don't process it yet.
         try
         {
            var resource:Resource = new resourceType();
            resource.Filename = filename;
            resource.Initialize(data);
            
            // These can be in the try since the catch will return.
            resource.IncrementReferenceCount();
            _resources[filename + resourceType] = resource;
         }
         catch(e:Error)
         {
            Logger.PrintError(this, "RegisterEmbeddedResources", "Could not instantiate resource " + filename + " due to error:\n" + e.toString());
            return;
         }
      }
      
      private function _Fail(resource:Resource, onFailed:Function, message:String):void
      {
         Logger.PrintError(this, "Load", message);
         if (onFailed != null)
            setTimeout(onFailed, 1, resource);
      }
      
      private var _resources:Dictionary = new Dictionary();
   }
}
