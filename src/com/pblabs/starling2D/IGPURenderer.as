/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2012 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.starling2D
{
	import starling.display.DisplayObject;

    /**
     * This interface is implemented by renderers that support rendering to the GPU
     * will be integrated with Starling framework.
     */
    public interface IGPURenderer
    {
        /**
         * Grabs the renderable container used to display the renderer on the GPU
         */
        function get displayObjectG2D():DisplayObject;
    }
}