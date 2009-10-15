/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.rendering2D.spritesheet
{
    import flash.geom.Rectangle;
    
    /**
     * Base interface for descriptions about how frames are laid out in a sprite sheet.
     */
    public interface ISpriteSheetDivider
    {
        /**
         * How many frames are in this sprite sheet?
         */ 
        function get frameCount():int;
        
        /**
         * Many times you want to infer information about frames based on data
         * from the sprite sheet. When the divider is assigned to a sprite sheet,
         * the sprite sheet passes itself to OwningSheet so you can store it and
         * get information from it.
         */
        function set owningSheet(value:SpriteSheetComponent):void;
        
        /**
         * Return the size of a frame, given the desired index and the source
         * image's dimensions.
         */
        function getFrameArea(index:int):Rectangle;
        
        /**
         * The MultiSpriteSheetHelper has to be able to clone dividers. So we
         * have a Clone method.
         */
        function clone():ISpriteSheetDivider;
    }
}