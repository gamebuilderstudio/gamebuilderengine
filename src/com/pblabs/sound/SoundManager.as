package com.pblabs.sound
{
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.engine.resource.ResourceManager;
    import com.pblabs.engine.resource.SoundResource;
    
    import flash.events.Event;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;
    import flash.utils.Dictionary;
    
    public class SoundManager
    {
        private static var _instance:SoundManager = null;
        
        public static const SFX_MIXER_CATEGORY:String = "sfx";
        public static const MUSIC_MIXER_CATEGORY:String = "music";
        
        private var _playing:Dictionary = new Dictionary();
        private var _transforms:Dictionary = new Dictionary();
        private var _muted:Dictionary = new Dictionary();
        private var _allMuted:Boolean = false;
        private var _concurrency:int = 0;
        
        public var muteTransform:SoundTransform = new SoundTransform(0, 0);
        public var defaultTransform:SoundTransform = new SoundTransform(1, 0);
        
        /**
         * The absolute maximum number of sounds that can be playing concurrently.
         * If this limit is reached new sounds are ignored.
         */
        public var maxConcurrentSounds:int = 5;
        
        /**
         * The singleton SoundManager instance.
         */
        public static function get instance():SoundManager
        {
            if (!_instance)
                _instance = new SoundManager();
            
            return _instance;
        }
        
        public function setTransform(mixerCategory:String, transform:SoundTransform):void
        {
            _transforms[mixerCategory] = transform;
        }
        
        protected var _fileCache:Object = {};
        
        public function playFile(uri:String, mixerCategory:String=SFX_MIXER_CATEGORY, loops:int=0, startDelay:Number=0.0):SoundChannel
        {
            // Play immediately if the file is present.
            if(_fileCache[uri])
                return play(_fileCache[uri] as SoundResource, mixerCategory, loops, startDelay);
            
            // Else, request it and play on success.
            ResourceManager.instance.load(uri, SoundResource, function(r:*):void
            {
                _fileCache[uri] = r;
                play(r as SoundResource, mixerCategory, loops, startDelay);
            });
            
            return null;
        }
        
        public function play(sound:SoundResource, mixerCategory:String=SFX_MIXER_CATEGORY, loops:int=0, startDelay:Number=0.0):SoundChannel
        {
            var info:SoundControllerInfo = new SoundControllerInfo();
            info.loops = loops;
            info.mixerCategory = mixerCategory;
            info.overrides = false;
            info.sound = sound;
            
            return playFromInfo(info);
        }
        
        public function playFromInfo(sci:SoundControllerInfo):SoundChannel
        {
            if (!sci  || !sci.sound)
            {
                Logger.warn(this, "play", "Tried to play a non-existant sound. Make sure your soundComponent is properly defined and your sound resource is loaded.");
                return null;
            }
            
            if (!shouldPlay(sci))
            {
                //TODO: Might want to queue or push out an old one, or something more interesting than just not playing the sound?
                Logger.print(this, "Not playing a sound due to the sound policy. There are probably too many playing right now.");
                return null;
            }
            
            var mixerTransform:SoundTransform = _transforms[sci.mixerCategory];
            var transform:SoundTransform = isMuted(sci.mixerCategory) ? muteTransform : mixerTransform;
            var channel:SoundChannel = sci.sound.soundObject.play(sci.startTime, sci.loops, transform ? transform : defaultTransform);
            
            if (!channel)
                return null;
            
            if (!_playing[sci.mixerCategory])
                _playing[sci.mixerCategory] = new Array();
            
            _concurrency++;    
            _playing[sci.mixerCategory].push(new SoundNote(channel, sci));
            channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteCallback);
            
            return channel;
        }
        
        public function stop(mixerCategory:String=null, channel:SoundChannel=null):void
        {
            var sounds:Array;
            var sound:SoundNote;
            
            if (mixerCategory)
            {
                var category:Array = _playing[mixerCategory];
                if (!category) 
                    return;
                
                for each (sound in category)
                {
                    _concurrency--;
                    sound.channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteCallback);   
                    sound.channel.stop();
                }
                
                delete _playing[mixerCategory];
            }
            
            if (channel)
            {
                for each (sounds in _playing)
                {
                    for (var i:int = 0; i < sounds.length; i++)
                    {
                        sound = sounds[i];
                        if (sound.channel === channel)
                        {
                            _concurrency--;
                            sounds.splice(i, 1);
                            sound.channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteCallback);   
                            sound.channel.stop();
                            break;
                        }
                    }
                }
            }
            
            if (!channel && !mixerCategory)
            {
                for each (sounds in _playing)
                {
                    for each (sound in sounds)
                    {
                        sound.channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteCallback);   
                        sound.channel.stop();
                    }
                }
                
                _concurrency = 0;
                _playing = new Dictionary();
            }
        }
        
        public function isMuted(mixerCategory:String=null):Boolean
        {
            return _allMuted || (mixerCategory && _muted[mixerCategory]);
        }
        
        public function mute(mixerCategory:String=null):void
        {
            var sounds:Array;
            var sound:SoundNote;
            
            if (mixerCategory)
            {
                _muted[mixerCategory] = true;
                
                var category:Array = _playing[mixerCategory];
                if (!category) 
                    return;
                
                for each (sound in category)
                sound.channel.soundTransform = muteTransform;
            }
            else
            {
                _allMuted = true;
                for each (sounds in _playing)
                {
                    for each (sound in sounds)
                    sound.channel.soundTransform = muteTransform;
                }
            }
        }
        
        public function unMute(mixerCategory:String=null):void
        {
            var sounds:Array;
            var sound:SoundNote;
            var transform:SoundTransform;
            if (mixerCategory)
            {
                _muted[mixerCategory] = false;
                
                var category:Array = _playing[mixerCategory];
                if (!category) 
                    return;
                
                for each (sound in category)
                {
                    transform = _transforms[sound.sound.mixerCategory];
                    sound.channel.soundTransform = transform ? transform : defaultTransform;
                }
            }
            else
            {
                _allMuted = false;
                for each (sounds in _playing)
                {
                    for each (sound in sounds)
                    {
                        transform = _transforms[sound.sound.mixerCategory];
                        sound.channel.soundTransform = transform ? transform : defaultTransform;
                    }
                }
            }
        }
        
        public function setVolume(volume:Number=1, mixerCategory:String=null):void
        {
            if (mixerCategory)
            {
                var oldTransform:SoundTransform = _transforms[mixerCategory];
                
                if (oldTransform)
                {
                    oldTransform.volume = volume;
                    return;
                }
                
                var newTransform:SoundTransform = new SoundTransform(volume);
                setTransform(mixerCategory, newTransform);
                
                var category:Array = _playing[mixerCategory];
                if (!category)
                    return;
                
                for each (var sound:SoundNote in category)
                sound.channel.soundTransform = newTransform;
            }
            else
            {
                defaultTransform.volume = volume;
            }
        }
        
        private function soundCompleteCallback(event:Event):void
        {
            _concurrency--;
            
            for each (var sounds:Array in _playing)
            {
                for (var i:int = 0; i < sounds.length; i++)
                {
                    if (event.target === sounds[i].channel)
                    {
                        sounds.splice(i, 1);
                        break;
                    }
                }
            }
        }
        
        private function shouldPlay(sound:SoundControllerInfo):Boolean
        {
            //TODO: Probably want to make this extensible through something like an ISoundPolicy interface
            return _concurrency < maxConcurrentSounds;
        }
    }
}

import flash.media.SoundChannel;
import com.pblabs.sound.SoundControllerInfo;

final class SoundNote
{
    public function SoundNote(channel:SoundChannel, sound:SoundControllerInfo)
    {
        this.channel = channel;
        this.sound = sound;
    }
    
    public var channel:SoundChannel;
    public var sound:SoundControllerInfo;
}
