package com.pblabs.engine.resource 
{
   import com.pblabs.engine.PBE;
   import com.pblabs.engine.resource.ResourceEvent;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   /**
    * ...
    * @author Juank
    */
   public class ExternalResourceFile extends EventDispatcher
   {
      private var _loader:Loader = new Loader();
      private var _appContext:LoaderContext;
      
      private var _fileName:String;
      
      /**
       * loader gett and set
       */
      public function get loader():Loader
      {
         return _loader;
      }

      public function set loader(value:Loader):void
      {
         _loader = value;
      }

      public function get isLoaded():Boolean
      {
         return _loader.contentLoaderInfo.bytesTotal > 5 && 
            _loader.contentLoaderInfo.bytesLoaded >= _loader.contentLoaderInfo.bytesTotal;
      }
      
      private var _didFail:Boolean = false;
      
      public function get didFail():Boolean 
      { 
         return _didFail; 
      }
      
      public function get fileName():String 
      { 
         return _fileName; 
      }
      
      public function ExternalResourceFile(useOwnDomain:Boolean = true) 
      {
         _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
         _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, failHandler);
         
         var appDomain:ApplicationDomain;
         
         if (useOwnDomain)
         {
            appDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
         }
         else
         {
            appDomain = ApplicationDomain.currentDomain;
         }
         
         _appContext = new LoaderContext(false, appDomain);
      }
      
      private function failHandler(e:IOErrorEvent):void 
      {
         _didFail = true;
         dispatchEvent(new ResourceEvent(ResourceEvent.FAILED_EVENT, null));
      }
      
      private function completeHandler(e:Event):void 
      {
         PBE.callLater(function():void
         {
            dispatchEvent(new ResourceEvent(ResourceEvent.LOADED_EVENT, null));
         }, []);
      }
      
      public function load(request:URLRequest):void
      {
         _loader.load(request, _appContext);
         _fileName = request.url;
      }
      
      public function unload():void
      {
         _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
         _loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, failHandler);
         _loader.unload();
         _loader = null;
         _appContext = null;
      }
   }

}