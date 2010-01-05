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
    import com.pblabs.engine.debug.Logger;
    
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
     * @eventType com.pblabs.engine.resource.ResourceEvent.LOADED_EVENT
     */
    [Event(name="LOADED_EVENT", type="com.pblabs.engine.resource.ResourceEvent")]
    
    /**
     * @eventType com.pblabs.engine.resource.ResourceEvent.FAILED_EVENT
     */
    [Event(name="FAILED_EVENT", type="com.pblabs.engine.resource.ResourceEvent")]
    
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
     */
    public class Resource extends EventDispatcher
    {
        /**
         * The filename the resource data was loaded from.
         */
        public function get filename():String
        {
            return _filename;
        }
        
        /**
         * @private
         */
        public function set filename(value:String):void
        {
            if (_filename != null)
            {
                Logger.warn(this, "set filename", "Can't change the filename of a resource once it has been set.");
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
        public function get isLoaded():Boolean
        {
            return _isLoaded;
        }
        
        /**
         * Whether or not the resource failed to load. This is only valid after the resource
         * has loaded, so being false only verifies a successful load if IsLoaded is true.
         * 
         * @see #IsLoaded
         */
        public function get didFail():Boolean
        {
            return _didFail;
        }
        
        /**
         * The number of places this resource is currently referenced from. When this reaches
         * zero, the resource will be unloaded.
         */
        public function get referenceCount():int
        {
            return _referenceCount;
        }
        
        /**
         * The Loader object that was used to load this resource.
         * This is set to null after onContentReady returns true.
         */
        protected function get resourceLoader():Loader
        {
            return _loader;
        }
        
        /**
         * Loads resource data from a file.
         * 
         * @param filename The filename or url to load data from. A ResourceEvent will be
         * dispatched when the load completes - LOADED_EVENT on successful load, or
         * FAILED_EVENT if the load fails.
         */
        public function load(filename:String):void
        {
            _filename = filename;
            
            var loader:URLLoader = new URLLoader();
            loader.dataFormat = URLLoaderDataFormat.BINARY;
            loader.addEventListener(Event.COMPLETE, onDownloadComplete);
            loader.addEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadSecurityError);
            
            var request:URLRequest = new URLRequest();
            request.url = filename;
            loader.load(request);
            
            // Keep reference so the URLLoader isn't GC'ed.
            _urlLoader = loader;
        }
        
        /**
         * initializes the resource with data from a byte array. This implementation loads
         * the data with a content loader. If that behavior is not needed (XML doesn't need
         * this, for example), this method can be overridden. Subclasses that do override this
         * method must call onLoadComplete when they have finished loading and conditioning
         * the byte array.
         * 
         * @param data The data to initialize the resource with.
         */
        public function initialize(data:*):void
        {
            if(!(data is ByteArray))
                throw new Error("Default Resource can only process ByteArrays!");
            
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
            loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadSecurityError);
            loader.loadBytes(data);
            
            // Keep reference so the Loader isn't GC'ed.
            _loader = loader;
        }
        
        /**
         * Increments the number of references to the resource. This should only ever be
         * called by the ResourceManager.
         */
        public function incrementReferenceCount():void
        {
            _referenceCount++;
        }
        
        /**
         * Decrements the number of references to the resource. This should only ever be
         * called by the ResourceManager.
         */
        public function decrementReferenceCount():void
        {
            _referenceCount--;
        }
        
        /**
         * This method will be used by a Resource Provider to indicate that this
         * resource has failed loading
         */
        public function fail(message:String):void
        {
            onFailed(message);        	
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
        protected function onContentReady(content:*):Boolean
        {
            return false;
        }
        
        /**
         * Called when loading and conditioning of the resource data is complete. This
         * must be called by, and only by, subclasses that override the initialize
         * method.
         * 
         * @param event This can be ignored by subclasses.
         */
        protected function onLoadComplete(event:Event = null):void
        {
            try
            {
                if (onContentReady(event ? event.target.content : null))
                {
                    _isLoaded = true;
                    _urlLoader = null;
                    _loader = null;
                    dispatchEvent(new ResourceEvent(ResourceEvent.LOADED_EVENT, this));
                    return;
                }
                else
                {
                    onFailed("Got false from onContentReady - the data wasn't accepted.");
                    return;
                }
            }
            catch(e:Error)
            {
                Logger.error(this, "Load", "Failed to load! " + e.toString());
            }
            
            onFailed("The resource type does not match the loaded content.");
            return;
        }
        
        private function onDownloadComplete(event:Event):void
        {
            var data:ByteArray = ((event.target) as URLLoader).data as ByteArray;
            initialize(data);
        }
        
        private function onDownloadError(event:IOErrorEvent):void
        {
            onFailed(event.text);
        }
        
        private function onDownloadSecurityError(event:SecurityErrorEvent):void
        {
            onFailed(event.text);
        }
        
        protected function onFailed(message:String):void
        {
            _isLoaded = true;
            _didFail = true;
            Logger.error(this, "Load", "Resource " + _filename + " failed to load with error: " + message);
            dispatchEvent(new ResourceEvent(ResourceEvent.FAILED_EVENT, this));
            
            _urlLoader = null;
            _loader = null;
        }
        
        protected var _filename:String = null;
        private var _isLoaded:Boolean = false;
        private var _didFail:Boolean = false;
        private var _urlLoader:URLLoader;
        private var _loader:Loader;
        private var _referenceCount:int = 0;
    }
}