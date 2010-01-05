package com.pblabs.sound
{
	import com.pblabs.engine.entity.EntityComponent;
	import com.pblabs.engine.entity.PropertyReference;
	
	import flash.events.Event;
	import flash.media.SoundChannel;
	
	public class SoundController extends EntityComponent
	{
        /**
         * Sounds, indexed by name.
         *
         * @see SoundControllerInfo
         */
        [TypeHint(type="com.pblabs.sound.SoundControllerInfo")]
        public var sounds:Array = new Array();

        /**
         * Property that indicates the name of the current sound.
         *
         * We read this each tick (or after the playSoundEvent, if specified) 
         * to determine if we should play a sound.
         */
        public var currentSoundReference:PropertyReference;

        /**
        * Whether we should stop any currently playing sounds when this component is removed.
        */
        public var stopOnRemove:Boolean = false;

        /**
        * If set, the name of the event to listen to for sound changes on the 
        * owning entity.
        * 
        * No data is read from this event, it is simply a signal to play the 
        * sound referenced by currentSoundReference.
        */
        public var playSoundEvent:String;

        /**
        * All the sound we're currently playing for this entity.
        * We track this so we can honor the overrides property and stop all sounds when playing a new one.
        */
        private var _soundsPlaying:Array = new Array();
        
        private function soundCompleteCallback(event:Event):void
        {
            for (var i:int = 0; i < _soundsPlaying.length; i++)
            {
                if (_soundsPlaying[i] === event.target)
                {
                    event.target.removeEventListener(Event.SOUND_COMPLETE, soundCompleteCallback);
                    _soundsPlaying.splice(i, 1);
                }
            }
        }
        
        private function stopCurrentSounds():void
        {
            for each (var s:SoundChannel in _soundsPlaying)
            {
                s.removeEventListener(Event.SOUND_COMPLETE, soundCompleteCallback);
                SoundManager.instance.stop(null, s);
            }
            
            _soundsPlaying = new Array();
        }

        override protected function onAdd(): void
        {
            super.onAdd();
            
            if (owner.eventDispatcher && playSoundEvent)
                owner.eventDispatcher.addEventListener(playSoundEvent, soundChangedHandler);
        }
        
        override protected function onRemove() : void
        {
            super.onRemove();
            
            if (owner.eventDispatcher && playSoundEvent)
                owner.eventDispatcher.removeEventListener(playSoundEvent, soundChangedHandler);
                
            if (stopOnRemove)
                stopCurrentSounds();
        }
        
        private function soundChangedHandler(event:Event):void
        {
            // Grab the the sound info for this sound.
            var sound:SoundControllerInfo = null;
            if (currentSoundReference)
            {
                var nextSoundName:String = owner.getProperty(currentSoundReference);
                sound = sounds[nextSoundName];
            }
            
            // There's no sound to play. No big deal.
            // We make sure to only send a given sound event to the sound manager once.
            if (!sound)
                return;

            if (!sound.soundComponent)
                throw new Error("Sound info had no sound component!");
                
            // Fire start event.
            if (sound.startEvent)
                owner.eventDispatcher.dispatchEvent(new Event(sound.startEvent));

            // This sound wants to override all other sounds. So, we stop them all.
            if (sound.overrides)
                stopCurrentSounds();
            
            var channel:SoundChannel = SoundManager.instance.playFromInfo(sound);
            if (channel)
            {
                _soundsPlaying.push(channel);
                channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteCallback);
            }
            else
            {
                // The sound did not play due to SoundManager restrictions of some sort.
                // Don't think we want to log this because it could be pretty common in a complex game.
            }
        }
 	}
}