package com.pblabs.sound
{
    import com.pblabs.engine.components.TickedComponent;
    import com.pblabs.engine.resource.MP3Resource;
    
    import flash.media.SoundChannel;
    
    /**
     * Simple component to manage background music.
     */
    public class BackgroundMusicComponent extends TickedComponent
    {
        private var _firstStart:Boolean = true;
        private var _playing:Boolean;
        private var _start:Boolean;
        private var _channel:SoundChannel;
        
        public var music:MP3Resource;
        public var autoStart:Boolean = true;
        
        public function start():void
        {
            _start = true;
        }
        
        public function stop():void
        {
            if (!_playing)
                return;
            
            SoundManager.instance.stop(null, _channel);
            _playing = false;
            _channel = null;
            _start = false;
            _firstStart = false;
        }
        
        override public function onTick(tickRate:Number) : void
        {
            if (_playing)
                return;
            
            _start = _start || (autoStart && _firstStart);
            
            if (!_start || !music || !music.soundObject)
                return;
            
            _channel = SoundManager.instance.play(music, SoundManager.MUSIC_MIXER_CATEGORY, int.MAX_VALUE, 0);
            if (_channel)
            {
                _playing = true;
                _start = false;
                _firstStart = false;
            }
        }
        
        override protected function onRemove() : void
        {
            super.onRemove();
            
            stop();
        }
    }
}