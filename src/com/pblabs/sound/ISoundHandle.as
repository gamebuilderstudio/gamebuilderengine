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
    import flash.media.SoundTransform;

    /**
     * A reference to an actively playing sound. Use ISoundManager.play() to
     * create these. You can pause/resume/stop the sound, as well as adjust its
     * volume and pan.
     */
    public interface ISoundHandle
    {
        /**
         * Pause playback; can continue it with resume().
         */
        function pause():void;
        /**
         * Resume playback paused with pause().
         */
        function resume():void;
        
        /**
         * Irrevocably stop playback. The sound is removed from the SoundManager,
         * and related resources are released.
         */
        function stop():void;

        /**
         * Access the sound's SoundTransform.
         */
        function set transform(value:SoundTransform):void;
        function get transform():SoundTransform;

        /**
         * Adjust the sound's volume.
         */
        function set volume(value:Number):void;
        function get volume():Number;
        
        /**
         * Adjust the panning (-1 is left, 1 is right) for the sound.
         */
        function set pan(value:Number):void;
        function get pan():Number;
        
        /**
         * Under what category is the sound being tracked by the SoundManager?
         */
        function get category():String;
        
        /**
         * Returns whether or not this sound is currently playing
         */
        function get isPlaying():Boolean;
    }
}