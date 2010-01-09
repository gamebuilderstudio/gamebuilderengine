package com.pblabs.sound
{
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.components.TickedComponent;
    import com.pblabs.engine.resource.MP3Resource;
    
    import flash.media.SoundChannel;
    
    /**
     * Simple component to manage background music.
     */
    public class BackgroundMusicComponent extends TickedComponent
    {
        protected var handle:SoundHandle;
        
        public var music:MP3Resource;
        public var autoStart:Boolean = true;
        
        public function start():void
        {
            if(!handle)
                handle = PBE.soundManager.play(music, SoundManager.MUSIC_MIXER_CATEGORY, 0, int.MAX_VALUE);            
            else if(!handle.isPlaying);
                handle.resume();
        }
        
        public function stop():void
        {
            handle.stop();
        }
        
        override protected function onAdd() : void
        {
            super.onAdd();
            
            if(autoStart)
                start();
        }
        
        override protected function onRemove() : void
        {
            super.onRemove();
            
            stop();
        }
    }
}