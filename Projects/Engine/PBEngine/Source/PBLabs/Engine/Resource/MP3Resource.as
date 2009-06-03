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
   import flash.media.Sound;
   import flash.events.*;
   import flash.net.URLRequest;
   
   import PBLabs.Engine.Resource.Resource;
   
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
      
      public override function Load(filename:String):void
      {
         _filename = filename;
         
         var request:URLRequest = new URLRequest(filename);
         _loadingSound = new Sound();
         _loadingSound.addEventListener(Event.COMPLETE, _OnSoundLoadComplete);
         _loadingSound.addEventListener(IOErrorEvent.IO_ERROR, _OnSoundDownloadError);
         _loadingSound.load(request);
      }
      
      private function _OnSoundLoadComplete(event:Event):void
      {
         SoundObject = _loadingSound;
         _OnLoadComplete();
      }
      
      private function _OnSoundDownloadError(event:IOErrorEvent):void
      {
         _OnFailed(event.text);
      }
      
      /**
       * @inheritDoc
       */
      protected override function _OnContentReady(content:*):Boolean 
      {
         return SoundObject != null;
      }
      
      // store the sound here until it's loaded
      private var _loadingSound:Sound;
   }
}