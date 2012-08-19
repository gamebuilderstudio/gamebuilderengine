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
	import com.pblabs.rendering2D.spritesheet.FrameNote;
	import com.pblabs.rendering2D.spritesheet.SpriteContainerComponent;
	
	import flash.display.BitmapData;
	
	import starling.textures.Texture;
	
	public class SpriteContainerComponentG2D extends SpriteContainerComponent
	{
		public function SpriteContainerComponentG2D()
		{
			super();
		}
		
		override public function getFrame(index:int, direction:Number=0.0):BitmapData{ return super.getFrame(index, direction); }
		
		/**
		 * Gets the Starling Texture for a frame at a specified index.
		 * 
		 * @param index The index of the frame to retrieve.
		 * @param direction The direction of the frame to retrieve in degrees. This
		 *                  can be ignored if there is only 1 direction per frame.
		 * 
		 * @return The Texture for the specified frame, or null if it doesn't exist.
		 */
		public function getTexture(index:int, direction:Number=0.0):Texture
		{
			if(!isLoaded)
				return null;
			
			// Make sure direction is in 0..360.
			while (direction < 0)
				direction += 360;
			
			while (direction > 360)
				direction -= 360;
			
			// Easy case if we only have one direction per frame.
			if (directionsPerFrame == 1)
				return getRawTexture(index);
			
			// Otherwise we have to do a search.
			
			// Make sure we have data to fulfill our requests from.
			if (frameNotes == null)
				generateFrameNotes();
			
			// Look for best match.
			var bestMatchIndex:int = -1;
			var bestMatchDirectionDistance:Number = Number.POSITIVE_INFINITY;
			
			for (var i:int = 0; i < frameNotes.length; i++)
			{
				var note:FrameNote = frameNotes[i];
				if (note.Frame != index)
					continue;
				
				var distance:Number = Math.min(Math.abs(note.Direction - direction), note.Direction + 360 - direction);
				if (distance < bestMatchDirectionDistance)
				{
					// This one is better on both frame and heading.
					bestMatchDirectionDistance = distance;
					bestMatchIndex = note.RawFrame;
				}
			}
			
			// Return the bitmap.
			if (bestMatchIndex >= 0)
				return getRawTexture(bestMatchIndex);
			
			return null;
		}
		
		override protected function getRawFrame(index:int):BitmapData{ return super.getRawFrame(index); }
		/**
		 * Gets the frame Texture at the specified index. This does not take direction into
		 * account.
		 */
		protected function getRawTexture(index:int):Texture
		{
			if (frames == null)
				buildFrames();
			
			if (frames == null)
				return null;
			
			if ((index < 0) || (index >= rawFrameCount))
				return frames[0];
			
			return frames[index];  
		}
	}
}