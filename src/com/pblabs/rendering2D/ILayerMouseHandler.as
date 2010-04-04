/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.rendering2D
{
    import flash.geom.Point;
    import com.pblabs.engine.core.ObjectType;

    /**
     * Implemented by layers which do their own entities-under-point logic. 
     */
	public interface ILayerMouseHandler
	{
        /**
         * @see IScene2D.getRenderersUnderPoint
         */ 
        function getRenderersUnderPoint(scenePosition:Point, mask:ObjectType, results:Array):void;
	}
}