package PBLabs.MP3Sound
{
   import PBLabs.Engine.Resource.Resource;
   
   import flash.media.Sound;
   import flash.utils.ByteArray;
   
   import org.audiofx.mp3.MP3FileReferenceLoader;
   import org.audiofx.mp3.MP3SoundEvent;
   
   /**
    * This is a Resource subclass for mp3 audio files.
    */
   public class MP3Resource extends Resource
   {
      /**
       * The loaded sound.
       */
      public var SoundObject:Sound = null;
      
      /**
       * In order to get a Sound object from a ByteArray, the data first needs to be
       * packed in a swf file. Then, from the swf file, a Sound object can be pulled
       * out. The MP3Loader library (from here: http://www.flexiblefactory.co.uk/flexible/?p=46)
       * handles this.
       */
      public override function Initialize(data:ByteArray):void
      {
         var loader:MP3FileReferenceLoader = new MP3FileReferenceLoader();
         loader.addEventListener(MP3SoundEvent.COMPLETE, _OnLoaded);
         loader.getSoundFromByteArray(data);
      }
      
      /**
       * @inheritDoc
       */
      protected override function _OnContentReady(content:*):Boolean 
      {
         return SoundObject != null;
      }
      
      private function _OnLoaded(event:MP3SoundEvent):void
      {
         SoundObject = event.sound;
         _OnLoadComplete();
      }
   }
}