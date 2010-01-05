package com.pblabs.sound
{
    import com.pblabs.engine.resource.SoundResource;
    

	public final class SoundControllerInfo
	{
        /**
         * The number of times this sound should loop.
         */
        public var loops:int = 0;

        /**
         * Resource containing the sound.
         */
        public var sound:SoundResource;

        /**
         * Name of event to fire on the entity when this sound starts.
         */
        public var startEvent:String;
        
        /**
        * The initial position, in milliseconds, at which playback should start.
        * This is passed directly to Sound.play().
        */
        public var startTime:Number = 0.0;
        
        /**
        * The mixer category for this sound. This is used to control selective volume control, muting, etc.
        * The category names are arbitrary and it's up to you to determine their behavior by using the
        * SoundManager.
        * 
        * If this is null bad things will happen.
        */
        public var mixerCategory:String = SoundManager.SFX_MIXER_CATEGORY;
        
        /**
        * If true, we will stop all previous sounds on this entity when we start playing this sound. 
        */
        public var overrides:Boolean = false;
    }
}