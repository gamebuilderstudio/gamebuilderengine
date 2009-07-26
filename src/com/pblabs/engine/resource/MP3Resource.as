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
   import flash.media.Sound;
   import flash.events.*;
   import flash.net.URLRequest;
   
   import com.pblabs.engine.resource.Resource;
   
   [EditorData(extensions="mp3")]
   
   /**
    * This is a Resource subclass for mp3 audio files.
    */
   public class MP3Resource extends Resource
   {
      /**
       * The loaded sound.
       */
      public var SoundObject:Sound = null;
      
      public override function load(filename:String):void
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
         SoundObject = _loadingSound;
         onLoadComplete();
      }
      
      private function onSoundDownloadError(event:IOErrorEvent):void
      {
         onFailed(event.text);
      }
      
      public override function initialize(d:*):void
      {
         SoundObject = d;
         onLoadComplete();
      }
      
      /**
       * @inheritDoc
       */
      protected override function onContentReady(content:*):Boolean 
      {
         return SoundObject != null;
      }
      
      // store the sound here until it's loaded
      private var _loadingSound:Sound;
   }
}