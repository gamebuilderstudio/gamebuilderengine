package com.pblabs.sound
{
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;

    /**
     * Track an active sound. You should only use ISoundHandle, not access this
     * directly.
     */
    internal class SoundHandle implements ISoundHandle
    {
        public function SoundHandle(_manager:SoundManager, _sound:Sound, __category:String, _pan:Number, _loopCount:int, _startDelay:Number)
        {
            manager = _manager;
            sound = _sound;
            _category = __category;
            pan = _pan;
            loopCount = _loopCount;
            pausedPosition = _startDelay;
            
            resume();
        }
        
        public function get transform():SoundTransform
        {
            return channel.soundTransform;
        }

        public function set transform(value:SoundTransform):void
        {
            dirty = true;
            channel.soundTransform = value;
        }

        public function get volume():Number
        {
            return _volume;
        }

        public function set volume(value:Number):void
        {
            dirty = true;
            _volume = value;
        }
        
        public function get pan():Number
        {
            return _pan;
        }
        
        public function set pan(value:Number):void
        {
            dirty = true;
            _pan = value;
        }
        
        public function get category():String
        {
            return _category;
        }

        public function pause():void
        {
            pausedPosition = channel.position;
            channel.stop();
        }
        
        public function resume():void
        {
            dirty = true;
            channel = sound.play(pausedPosition)
        }
        
        public function stop():void
        {
            pause();
            
            // Remove from the manager.
            manager.removeSoundHandle(this);
        }
        
        internal var manager:SoundManager;
        internal var dirty:Boolean = true;
        internal var _category:String;
        
        internal var sound:Sound;
        internal var channel:SoundChannel;

        protected var pausedPosition:Number = 0;
        protected var loopCount:int = 0;
        protected var _volume:Number = 1;
        protected var _pan:Number = 0;
        
    }
}