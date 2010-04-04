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
     * Interface for sound managers.
     */
    public interface ISoundManager
    {
        /**
         * Play a supplied sound, returning a ISoundHandle which allows management
         * of the sound while it is playing. The sound is kept in memory for
         * responsive playback.
         * 
         * @param sound A SoundResource, string indicating a URI, or a Sound to 
         *        play.
         * @param loopCount How many times to repeat this sound? 0 to play it 
         *        one time, 1 to repeat once, int.MAX_VALUE for infinite loop.
         * @param startDelay How far to skip ahead into the sound when we start 
         *        playing it.
         * @param resourceType The PBE resource type for the sound. Defaults to 
         *        MP3Resource if no value is provided. It must be a subclass of
         *        SoundResource. This parameter is only used if sound is a string 
         *        and a resource needs to be loaded.
         */
        function play(sound:*, category:String = "sfx", pan:Number = 0.0, loopCount:int = 1, startDelay:Number = 0.0, resourceType:Class=null):SoundHandle;

        /**
         * Stream an MP3 or other Flash-compatible file from a URL. This is useful
         * for background music. Playback begins as soon as possible, before the
         * download completes.
         * 
         * @see play()
         */
        function stream(url:String, category:String = "sfx", pan:Number = 0.0, loopCount:int = 1, startDelay:Number = 0.0):SoundHandle;
        
        /**
         * When true, all sound playback is muted.
         */
        function set muted(value:Boolean):void;
        function get muted():Boolean;

        /**
         * The SoundManager volume controls global sound playback volume.
         */
        function set volume(value:Number):void;
        function get volume():Number;
        
        /**
         * For sanity purposes, all categories must be known to the manager. This
         * prevents typos and other problems when specifying categories in the other
         * calls. Before playing sounds or setting properties on a category, make
         * sure to call createCategory first.
         * @param category Name of the category to create.
         */
        function createCategory(category:String):void;
        
        /**
         * If you wish to remove an existing category, removeCategory will do this for you. 
         * @param category Name of the category to remove.
         */
        function removeCategory(category:String):void;
        
        /**
         * Mute a named category of sounds.
         * @param category Name of the category. (You might have to create it
         *        with createCategory first.)
         * @param muted If true, mute the sounds. If false, return them to their
         *        normal volume.
         */
        function setCategoryMuted(category:String, muted:Boolean):void;
        function getCategoryMuted(category:String):Boolean;
        
        /**
         * Adjust the volume of a named category of sounds.
         * @param category Name of the category. (You might have to create it
         *        with createCategory first.)
         * @param volume Value between 0..1 to use as a new volume level.
         */
        function setCategoryVolume(category:String, volume:Number):void;
        function getCategoryVolume(category:String):Number;
        
        /**
         * Adjust the SoundTransform for a given category.
         * @param category Name of the category. (You might have to create it
         *        with createCategory first.)
         * @param transform New SoundTransform to apply to this category.
         */
        function setCategoryTransform(category:String, transform:SoundTransform):void;
        function getCategoryTransform(category:String):SoundTransform; 
        
        /**
         * Stop all the sounds playing in a category.
         */
        function stopCategorySounds(category:String):void

        /**
         * Stop all the sounds playing in the SoundManager.
         */
        function stopAll():void

        /**
         * Fetch all the SoundHandles in the specified category and store them 
         * in the provided array.
         */
        function getSoundHandlesInCategory(category:String, outArray:Array):void        
    }
}