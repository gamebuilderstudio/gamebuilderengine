/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2012 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.rendering2D.spritesheet
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public interface ISpriteSheet
	{

		/**
		 * destroy is the manual distruction of the spritesheet for the cases when
		 * the spritesheet is used outside of an entity and needs to be cleaned up
		 **/
		function destroy():void;
		
		/**
		 * release the cached image frames if there are any and allow gc to kick in.
		 * This can cause a performance hit.
		 * @param checkReferenceCount : check the reference count before releasing
		 * 								and do not release if there are still references
		 **/
		function releaseCache(checkReferenceCount : Boolean = true):void;
		
		/**
		 * Gets the bitmap data for a frame at the specified index.
		 * 
		 * @param index The index of the frame to retrieve.
		 * @param direction The direction of the frame to retrieve in degrees. This
		 *                  can be ignored if there is only 1 direction per frame.
		 * 
		 * @return The bitmap data for the specified frame, or null if it doesn't exist.
		 */
		function getFrame(index:int, direction:Number=0.0):BitmapData;
			
		/**
		 * The bitmap data of the loaded image.
		 */
		function get imageData():BitmapData;
		function set imageData(data : BitmapData):void;
		
		/**
		 * The divider to use to chop up the sprite sheet into frames. If the divider
		 * isn't set, the image will be treated as one whole frame.
		 */
		function get divider():ISpriteSheetDivider;
		function set divider(value:ISpriteSheetDivider):void;

		/**
		 * The maximum bounds of all the frames in the spritesheet. So this will be the largest boundary 
		 * found in the sheet.
		 */
		function get bounds():Rectangle;

		function get isLoaded():Boolean;

		function get center():Point;
		function set center(value:Point):void;
		
		function get centered():Boolean;
		
		/**
		 * The total count of frames in the spritesheet
		 */
		function get frameCount():int;
		function set frameCount(val : int):void;

		function get cached():Boolean;
		function set cached(val : Boolean):void;
		
		function get isDestroyed():Boolean;
	}
}