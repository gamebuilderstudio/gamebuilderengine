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
     * State pertaining to a whole category of sounds. See ISoundManager for more
     * complete explanation, as this class is mostly used internally.
     */
    final public class SoundCategory
    {
        public var dirty:Boolean = false;
        public var muted:Boolean = false;
        public var transform:SoundTransform = new SoundTransform();
        
        /**
         * Accumulate the effects of multiple SoundCategories, applying them
         * to a specified SoundTransform.
         *  
         * @param targetTransform Transform to store results into.
         * @param muted Starting mute state.
         * @param pan Starting pan.
         * @param volume Starting volume.
         * @param categories List of categories to combine.
         */
        static public function applyCategoriesToTransform(muted:Boolean, pan:Number, volume:Number, ...categories):SoundTransform
        {
            // Accumulate the effects of the categories.
            for(var i:int=0; i<categories.length; i++)
            {
                var c:SoundCategory = categories[i] as SoundCategory;
                
                if(!c)
                    continue;
                
                if(c.muted)
                    muted = true;
                
                volume *= c.transform.volume;
                pan += c.transform.pan;
            }
            
            // Apply results to the target transform.
            var targetTransform:SoundTransform = new SoundTransform();
            targetTransform.volume = muted ? 0 : volume;
            targetTransform.pan = pan;
            return targetTransform;
        }
    }
}