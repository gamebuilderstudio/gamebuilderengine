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
    import flash.utils.ByteArray;
    
    import org.as3wavsound.WavSound;
    
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
			}else if(data is ByteArray){
				_soundObject = new WavSound(data as ByteArray);
			}
			processLoadedContent(_soundObject);
		}
		
		override public function dispose():void
		{
			_soundObject = null;
			super.dispose();
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
            return _soundObject != null;
        }
    }
}