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
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.media.Sound;
   import flash.net.URLRequest;

   [EditorData(extensions="mp3")]
   
   /**
    * This is a Resource subclass for mp3 audio files.
    */
   public class MP3Resource extends Resource
   {
      /**
       * The loaded sound.
       */
      public var soundObject:Sound = null;
      
      override public function load(filename:String):void
      {
         _filename = filename;
         
         var request:URLRequest = new URLRequest(filename);
         _loadingSound = new Sound();
         _loadingSound.addEventListener(Event.COMPLETE, onSoundLoadComplete);
         _loadingSound.addEventListener(IOErrorEvent.IO_ERROR, onSoundDownloadError);
         _loadingSound.load(request);
      }
      
      private function onSoundLoadComplete(event:Event):void
      {
         soundObject = _loadingSound;
         onLoadComplete();
      }
      
      private function onSoundDownloadError(event:IOErrorEvent):void
      {
         onFailed(event.text);
      }
      
      override public function initialize(d:*):void
      {
         soundObject = d;
         onLoadComplete();
      }
      
      /**
       * @inheritDoc
       */
      override protected function onContentReady(content:*):Boolean 
      {
         return soundObject != null;
      }
      
      // store the sound here until it's loaded
      private var _loadingSound:Sound;
   }
}