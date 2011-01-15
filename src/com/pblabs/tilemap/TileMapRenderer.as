/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.tilemap
{
	import com.pblabs.engine.core.*;
	import com.pblabs.engine.debug.*;
	import com.pblabs.rendering2D.BitmapRenderer;
	import com.pblabs.rendering2D.spritesheet.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	/**
	 * Handles rendering a TileMap object to the screen.  
	 * Requires a reference to the same tile sheet that was used when creating the tile map.
	 */
	public class TileMapRenderer extends BitmapRenderer
	{
		/**
		 * The tile map to render to the screen.
		 */ 
		public var map:TileMap;
		
		/**
		 * Add tile sheets to this array in the order that they were used in the tile map.
		 */ 
		[TypeHint(type="com.pblabs.rendering2D.spritesheet.SpriteSheetComponent")]
		public var tileSheets:OrderedArray = new OrderedArray();
		
		/**
		 * Don't render tile type zero. Useful for "overlay" tilemaps.
		 */ 
		public var skipTileZero:Boolean = true;
		
		// Parsed out, ready to render tiles in individual BitmapDatas.
		protected var _tileBitmaps:Array = new Array();
		
		// Dummy bitmap to display in place of broken tiles.
		protected var _borkBitmap:BitmapData = new BitmapData(32, 32, true, 0x77FF00FF);
		
		// We render tiles here before displaying them.
		private var frameCache:BitmapData;
		
		public var clampCameraToSelf:Boolean = true;
		
		public function TileMapRenderer()
		{
			// After most things, but before the scene.
			updatePriority = -1;
		}
		
		override public function onFrame(elapsed:Number) : void
		{
			if(!scene)
				return;
			
			if ( clampCameraToSelf )
			{
				scene.trackLimitRectangle = map.worldExtents;
			}
			
			// If we don't have any tiles yet...
			if(_tileBitmaps.length == 0)
			{
				// ... check that the tilesheets are loaded.
				for each(var sheet:SpriteContainerComponent in tileSheets)
				{
					if(!sheet.isLoaded)
					{
						// Make sure we will try to render again later.
						//invalidateRenderCache();
						return;
					}
				}
				
				// Great, set up the tile data then.
				for each(sheet in tileSheets)
				for(var i:int=0; i<sheet.frameCount; i++)
					_tileBitmaps.push(sheet.getFrame(i));
			}
			
			if (!frameCache || 
				frameCache.width  != scene.sceneViewBounds.width ||
				frameCache.height != scene.sceneViewBounds.height)
			{
				frameCache = new BitmapData(scene.sceneViewBounds.width, scene.sceneViewBounds.height, true, 0x00000000);
			}
			
			bitmapData = frameCache;
			
			var copyPoint:Point = new Point();
			
			var screenPosition:Point = scene.sceneViewBounds.topLeft;
			
			super.onFrame(elapsed);
			position = screenPosition.clone();
			updateTransform();
			
			var startX:int = (screenPosition.x / map.tileSize.x) - 1;
			var startY:int = (screenPosition.y / map.tileSize.y) - 1;
			var endX:int   = ((screenPosition.x + scene.sceneView.width) / map.tileSize.x) + 3;
			var endY:int   = ((screenPosition.y + scene.sceneView.height) / map.tileSize.y) + 3;
			
			startX = Math.max(0, startX);
			startY = Math.max(0, startY);
			endX = Math.min(map.width,  endX);
			endY = Math.min(map.height, endY);
			
			// Only need this once.
			var tileRect:Rectangle = new Rectangle(0,0, map.tileSize.x, map.tileSize.y);
			
			// Clear the bitmap!
			frameCache.lock();
			frameCache.fillRect(frameCache.rect, 0x00000000);
			
			// Now, draw all our tiles.
			for(var curX:int = startX; curX<endX; curX++)
			{
				for(var curY:int = startY; curY<endY; curY++)
				{
					var tileType:int = map.getTileType(curX, curY);
					if(skipTileZero && tileType==0)
						continue;
					
					// Get position of the tile.
					copyPoint.x = curX * map.tileSize.x;
					copyPoint.y = curY * map.tileSize.y;
					
					// Transform to screen space...
					var p:Point = scene.transformWorldToScene(copyPoint);
					
					// And offset it to be relative to our bitmap.
					copyPoint.x = p.x - _position.x;
					copyPoint.y = p.y - _position.y;
					
					if (tileType <= _tileBitmaps.length)
					{
						if ((tileType < 0) || (_tileBitmaps[tileType-1] == null))
							Logger.warn(this, "OnDraw", "Tried to display tile of type " + tileType.toString()); 
						else
							frameCache.copyPixels(_tileBitmaps[tileType-1], tileRect, copyPoint);
					} 
					else 
					{
						frameCache.copyPixels(_borkBitmap, tileRect, copyPoint);
					}
				}
			}
			
			frameCache.unlock();
		}
	}
}