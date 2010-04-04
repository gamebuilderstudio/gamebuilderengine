/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.sound
{
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.engine.debug.Profiler;
    
    import flash.events.Event;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;

    /**
     * Track an active sound. You should only use ISoundHandle, not access this
     * directly.
     * 
     * @see ISoundHandle See ISoundHandle for documentation on this class.
     * @inheritDocs
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
            if(!channel)
                return new SoundTransform();
            return channel.soundTransform;
        }

        public function set transform(value:SoundTransform):void
        {
            dirty = true;
            if(channel)
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
            playing = false;
        }
        
        public function resume():void
        {
            Profiler.enter("SoundHandle.resume");
            
            dirty = true;
            
            // Note: if pausedPosition is anything but zero, the loops will not reset properly.
            // For now, the ability to "pause" should be avoided.
            try
            {
                channel = sound.play(pausedPosition, loopCount);
                playing = true;                

                // notify when this sound is done (all loops completed)
                channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
            }
            catch(e:Error)
            {
                Logger.error(this, "resume", "Error starting sound playback: " + e.toString());
            }
            

            Profiler.exit("SoundHandle.resume");
        }
        
        /**
         * To correctly handle the pause scenario, we need to be notified at the end of each loop,
         * so that we can reset the sound's starting position to 0.
         */
        private function onSoundComplete(e:Event):void
        {
            // since we're tracking the number of loops, decrement the count
            loopCount -= 1;

            if(loopCount > 0)
            {
                pausedPosition = 0;
                resume();
            }
            else if(manager.isInPlayingSounds(this))
            {
                // Remove from the manager.
                manager.removeSoundHandle(this);
            }
        }
        
        public function stop():void
        {
            pause();
            
            if(manager.isInPlayingSounds(this))
            {
                // Remove from the manager.
                manager.removeSoundHandle(this);
            }
        }
        
        public function get isPlaying():Boolean
        {
            return playing;
        }
        
        internal var manager:SoundManager;
        internal var dirty:Boolean = true;
        internal var _category:String;
        internal var playing:Boolean;
        
        internal var sound:Sound;
        internal var channel:SoundChannel;

        protected var pausedPosition:Number = 0;
        protected var loopCount:int = 0;
        protected var _volume:Number = 1;
        protected var _pan:Number = 0;
        
    }
}