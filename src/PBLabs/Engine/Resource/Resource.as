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
   
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   
   /**
    * @eventType PBLabs.Engine.Resource.ResourceEvent.LOADED_EVENT
    */
   [Event(name="LOADED_EVENT", type="PBLabs.Engine.Resource.ResourceEvent")]
   
   /**
    * @eventType PBLabs.Engine.Resource.ResourceEvent.FAILED_EVENT
    */
   [Event(name="FAILED_EVENT", type="PBLabs.Engine.Resource.ResourceEvent")]
   
   /**
    * A resource contains data for a specific type of game asset. This base
    * class does not define what that type is, so subclasses should be created
    * and used for each different type of asset.
    * 
    * <p>The Resource class and any subclasses should never be instantiated
    * directly. Instead, use the ResourceManager class.</p>
    * 
    * <p>Usually, resources are created by loading data from a file, but this is not
    * necessarily a requirement</p>
    * 
    * @see ResourceManager
    * @see ../../../../../Examples/CreatingResources.html Creating Resources
    * @see ../../../../../Examples/UsingResources.html Using Resources
    */
   public class Resource extends EventDispatcher
   {
      /**
       * The filename the resource data was loaded from.
       */
      public function get Filename():String
      {
         return _filename;
      }
      
      /**
       * @private
       */
      public function set Filename(value:String):void
      {
         if (_filename != null)
         {
            Logger.PrintWarning(this, "set Filename", "Can't change the filename of a resource once it has been set.");
            return;
         }
         
         _filename = value;
      }
      
      /**
       * Whether or not the resource has been loaded. This only marks whether loading has
       * been completed, not whether it succeeded. If this is true, DidFail can be checked
       * to see if loading was successful.
       * 
       * @see #DidFail 
       */
      public function get IsLoaded():Boolean
      {
         return _isLoaded;
      }
      
      /**
       * Whether or not the resource failed to load. This is only valid after the resource
       * has loaded, so being false only verifies a successful load if IsLoaded is true.
       * 
       * @see #IsLoaded
       */
      public function get DidFail():Boolean
      {
         return _didFail;
      }
      
      /**
       * The number of places this resource is currently referenced from. When this reaches
       * zero, the resource will be unloaded.
       */
      public function get ReferenceCount():int
      {
         return _referenceCount;
      }
      
      public function Resource()
      {
      }
      
      /**
       * Loads resource data from a file.
       * 
       * @param filename The filename or url to load data from. A ResourceEvent will be
       * dispatched when the load completes - LOADED_EVENT on successful load, or
       * FAILED_EVENT if the load fails.
       */
      public function Load(filename:String):void
      {
         _filename = filename;
         
         var loader:URLLoader = new URLLoader();
         loader.dataFormat = URLLoaderDataFormat.BINARY;
         loader.addEventListener(Event.COMPLETE, _OnDownloadComplete);
         loader.addEventListener(IOErrorEvent.IO_ERROR, _OnDownloadError);
         loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _OnDownloadSecurityError);
         
         var request:URLRequest = new URLRequest();
         request.url = filename;
         loader.load(request);
         
         // Keep reference so the URLLoader isn't GC'ed.
         _UrlLoader = loader;
      }
      
      /**
       * Initializes the resource with data from a byte array. This implementation loads
       * the data with a content loader. If that behavior is not needed (XML doesn't need
       * this, for example), this method can be overridden. Subclasses that do override this
       * method must call _OnLoadComplete when they have finished loading and conditioning
       * the byte array.
       * 
       * @param data The data to initialize the resource with.
       */
      public function Initialize(data:*):void
      {
         if(!(data is ByteArray))
            throw new Error("Default Resource can only process ByteArrays!");
         
         var loader:Loader = new Loader();
         loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _OnLoadComplete);
         loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _OnDownloadError);
         loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _OnDownloadSecurityError);
         loader.loadBytes(data);

         // Keep reference so the Loader isn't GC'ed.
         _Loader = loader;
      }
      
      /**
       * Increments the number of references to the resource. This should only ever be
       * called by the ResourceManager.
       */
      public function IncrementReferenceCount():void
      {
         _referenceCount++;
      }
      
      /**
       * Decrements the number of references to the resource. This should only ever be
       * called by the ResourceManager.
       */
      public function DecrementReferenceCount():void
      {
         _referenceCount--;
      }
      
      /**
       * This is called when the resource data has been fully loaded and conditioned.
       * Returning true from this method means the load was successful. False indicates
       * failure. Subclasses must implement this method.
       * 
       * @param content The fully conditioned data for this resource.
       * 
       * @return True if content contains valid data, false otherwise.
       */
      protected function _OnContentReady(content:*):Boolean
      {
         return false;
      }
      
      /**
       * Called when loading and conditioning of the resource data is complete. This
       * must be called by, and only by, subclasses that override the Initialize
       * method.
       * 
       * @param event This can be ignored by subclasses.
       */
      protected function _OnLoadComplete(event:Event = null):void
      {
         try
         {
            if (_OnContentReady(event ? event.target.content : null))
            {
               _isLoaded = true;
               _UrlLoader = null;
               _Loader = null;
               dispatchEvent(new ResourceEvent(ResourceEvent.LOADED_EVENT, this));
               return;
            }
         }
         catch(e:Error)
         {
            Logger.PrintError(this, "Load", "Failed to load! " + e.toString());
         }
         
         _OnFailed("The resource type does not match the loaded content.");
         return;
      }
      
      private function _OnDownloadComplete(event:Event):void
      {
         var data:ByteArray = ((event.target) as URLLoader).data as ByteArray;
         Initialize(data);
      }
      
      private function _OnDownloadError(event:IOErrorEvent):void
      {
         _OnFailed(event.text);
      }
      
      private function _OnDownloadSecurityError(event:SecurityErrorEvent):void
      {
         _OnFailed(event.text);
      }
      
      protected function _OnFailed(message:String):void
      {
         _isLoaded = true;
         _didFail = true;
         Logger.PrintError(this, "Load", "Resource " + _filename + " failed to load with error: " + message);
         dispatchEvent(new ResourceEvent(ResourceEvent.FAILED_EVENT, this));
         
         _UrlLoader = null;
         _Loader = null;
      }
      
      protected var _filename:String = null;
      private var _isLoaded:Boolean = false;
      private var _didFail:Boolean = false;
      private var _UrlLoader:URLLoader;
      private var _Loader:Loader;
      private var _referenceCount:int = 0;
   }
}