/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.starling2D
{
	import com.pblabs.rendering2D.IScene2D;
	
	import flash.geom.Point;

    /**
     * Base interface for a GPU2d scene. A scene contains multiple layers, and has
     * a camera transform which is applied to pan/rotate/zoom the view. The scene
     * is responsible for tracking and rendering all the drawable objects in the
     * world.
     * 
     * @see DisplayObjectRenderer
     * @see DisplayObjectScene
     */
    public interface ISceneG2D extends IScene2D
    {
		/**
		 * Takes the global flash stage position and transforms it into coordinates relative to the 2D GPU scene taking the viewport
		 * into account.
		 */
		function transformScreenToG2DWorld(globalPos:Point):Point;
    }
}