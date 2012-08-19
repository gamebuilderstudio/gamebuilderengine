/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2012 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.starling2D.spritesheet
{
	import com.pblabs.rendering2D.spritesheet.ISpriteSheet;
	
	import starling.textures.Texture;
	
	public interface ISpriteSheetG2D extends ISpriteSheet
	{
		
		/**
		 * Gets the starling Texture for a frame at the specified index.
		 * 
		 * @param index The index of the frame to retrieve.
		 * @param direction The direction of the frame to retrieve in degrees. This
		 *                  can be ignored if there is only 1 direction per frame.
		 * 
		 * @return The Texture object for the specified frame, or null if it doesn't exist.
		 */
		function getTexture(index:int, direction:Number=0.0):Texture;
	}
}