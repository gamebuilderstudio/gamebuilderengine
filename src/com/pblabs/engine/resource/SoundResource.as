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

		override protected function onLoadComplete(event:Event = null):void
		{
			try
			{
				if (onContentReady(event ? (event as MP3SoundEvent).sound : null))
				{
					_isLoaded = true;
					if(_soundLoader){
						_soundLoader.removeEventListener(MP3SoundEvent.COMPLETE, onLoadComplete);
						_soundLoader = null;
					}
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

		/**
         * @return The Sound this resource contains.
         */
        public function get soundObject():Sound
        {
            throw new Error("You should only use subclasses of SoundResource.");
        }
    }
}