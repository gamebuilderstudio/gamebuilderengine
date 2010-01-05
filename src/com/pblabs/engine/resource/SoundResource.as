package com.pblabs.engine.resource
{
    import flash.media.Sound;

    /**
     * Parent class for any resources which provide Sound objects.
     */
    public class SoundResource extends Resource
    {
        /**
         * @return The Sound this resource contains.
         */
        public function get soundObject():Sound
        {
            throw new Error("You should only use subclasses of SoundResource.");
        }
    }
}