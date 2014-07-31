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
	 * A sprite sheet interface marker used to expose additional methods for retrieving frames by name instead of index only for dividers with frame names
	 */
	public interface ISpriteSheetNamedFramesDivider extends ISpriteSheetDivider
	{
		function getFrameNameByIndex(index:int):String;
		function getFrameByName(name:String):Rectangle;
		function getFrameIndexByName(name:String):int;
		function isLoaded():Boolean;
	}
}