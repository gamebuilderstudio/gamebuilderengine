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
    import flash.events.IOErrorEvent;
    import flash.media.Sound;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;
    
    import org.as3wavsound.WavSound;
    import org.as3wavsound.sazameki.core.AudioSetting;
    
    [EditorData(extensions="wav")]
    
    /**
     * Load Sounds from WAVs using the 3rd party WavSound class. This class mimics the same interface that the native Sound class has.
	 * You will need to use the wavObject getter to access the internal sound object because WAVSound does not extend the Sound Class.
     */
    public class WAVResource extends SoundResource
    {
        /**
         * The loaded sound.
         */
        protected var _soundObject:WavSound = null;
        
		override public function initialize(data:*):void
		{
			if(data is WavSound)
			{
				_soundObject = data as WavSound;
				onLoadComplete(null);
			}else if(data is ByteArray){
				_soundObject = new WavSound(data as ByteArray);
				onLoadComplete(null);
			}
		}
		
		override protected function onLoadComplete(event:Event = null):void
		{
			try
			{
				if (onContentReady(null))
				{
					_isLoaded = true;
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
		 * the accessor for getting at the raw sound object of this resource. This resource could not user the super soundObject
		 * accessor because Wav sounds do not extend the Sound class do to some flash framework issues.
		 * 
		 * #see http://code.google.com/p/as3wavsound/wiki/WavSound
		 **/
		public function get soundWAVObject():WavSound
		{
			return _soundObject;
		}
        
		override public function get soundObject():Sound
		{
			return null;
		}
		/**
         * @inheritDoc
         */
        override protected function onContentReady(content:*):Boolean 
        {
            return soundWAVObject != null;
        }
    }
}