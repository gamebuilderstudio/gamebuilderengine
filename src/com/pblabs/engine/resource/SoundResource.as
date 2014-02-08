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
    
    import flash.events.Event;
    import flash.media.Sound;
    
    import org.audiofx.mp3.MP3Loader;
    import org.audiofx.mp3.MP3SoundEvent;

    /**
     * Parent class for any resources which provide Sound objects.
     */
    public class SoundResource extends Resource
    {
		protected var _soundLoader : MP3Loader;

		override public function initialize(data:*):void
		{
			if(data is Sound)
			{
				onLoadComplete(new MP3SoundEvent(MP3SoundEvent.COMPLETE, data as Sound));
			}else{
				_soundLoader = new MP3Loader();
				_soundLoader.addEventListener(Event.COMPLETE, onLoadComplete);
				_soundLoader.getSoundFromByteArray(data);
			}
		}

		override protected function onContentReady(content:*):Boolean
		{
			if(content is Sound)
				return true;
			return false;
		}

		override protected function onLoadComplete(event:Event = null):void
		{
			processLoadedContent((event ? (event as MP3SoundEvent).sound : null));
			if(_soundLoader){
				_soundLoader.removeEventListener(MP3SoundEvent.COMPLETE, onLoadComplete);
				_soundLoader = null;
			}
		}

		/**
         * @return The Sound this resource contains.
         */
        public function get soundObject():Sound
        {
            throw new Error("You should only use subclasses of SoundResource.");
        }
    }
}