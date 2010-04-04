/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
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