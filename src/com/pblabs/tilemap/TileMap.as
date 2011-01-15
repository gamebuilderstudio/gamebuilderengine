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
	import com.pblabs.engine.resource.*;
	import com.pblabs.rendering2D.RayHitInfo;
	import com.pblabs.rendering2D.SimpleSpatialComponent;
	
	import flash.geom.*;
	
	/**
	 * Basic spatial class that implements a tilemap. Exists physically, cannot
	 * be rotated or moved (currently), and supports raycasts.
	 */
	public class TileMap extends SimpleSpatialComponent
	{
		/**
		 * Dimensions in tiles.
		 */ 
		public var width:int = 10, height:int = 10;
		
		/**
		 * The size of each tile in pixels.
		 */ 
		public var tileSize:Point = new Point(32,32);
		
		/**
		 * Map used internally for tracking tile types and flags.
		 */ 
		private var flagMap:FlagMap;
		
		/**
		 * If true, will tell the spatial manager to process the collisions for the tiles in this map.
		 *  If false, this will only be a display tile map and will not collide with objects in the game world.
		 */
		public var collisionActive:Boolean = false;
		
		
		public function TileMap()
		{
			registerForTicks = false;
		}
		
		protected override function onAdd() : void
		{
			if(!flagMap)
			{
				setMapSize(width, height);
			}
			super.onAdd();
		}
		
		public function setMapSize(x:int, y:int):void
		{
			width = x;
			height = y;
			size = new Point(width * tileSize.x, height * tileSize.y);
			
			//         super.onAdd();
			if ((!flagMap) || (flagMap.width != width) || (flagMap.height != height))
				flagMap = new FlagMap(width, height);
		}
		
		public function contains(x:int, y:int):Boolean
		{
			return ((x >= 0)    && (y >= 0) &&
				(x < width) && (y < height));
		}
		
		public function getTileType(x:int, y:int):int
		{
			return flagMap.getTileType(x, y);
		}
		
		public function setTileType(x:int, y:int, type:int):void
		{
			flagMap.setTileType(x,y,type);
		}
		
		public function getTileFlags(x:int, y:int):int
		{
			return flagMap.getTileFlags(x, y);
		}
		
		public function setTileFlags(x:int, y:int, flags:int):void
		{
			flagMap.setTileFlags(x, y, flags);
		}
		
		public override function get worldExtents():Rectangle
		{
			return new Rectangle(0, 0, width * tileSize.x, height * tileSize.y);
		}
		
		private function rayVsBox(start:Point, end:Point, box:Rectangle, outInfo:RayHitInfo):Boolean
		{
			// Based on the N collision tutorials.
			
			// Get at the box data.
			var bx:Number = box.x + box.width * 0.5;
			var by:Number = box.y + box.height * 0.5;
			var xw:Number = box.width * 0.5;
			var yw:Number = box.height * 0.5;
			
			var px:Number = start.x, py:Number = start.y;
			var dx:Number = end.x - start.x, dy:Number = end.y - start.y;
			
			//use woo-based ray-vs-AABB
			
			//step 1: find the two AABB edges closest to the ray origin
			//note that we do this 
			var xval:Number, yval:Number;//these store the "potential candidate" sides
			if(dx > 0)
			{
				//origin is left of box; test min. edge
				xval = bx - xw;
			}
			else
			{
				//origin is right of box; test max. edge
				xval = bx + xw;
			}
			
			if(dy > 0)
			{
				//origin is above box; test min. edge
				yval = by - yw;
			}
			else
			{
				//origin is below box; test max. edge
				yval = by + yw;
			}
			
			//step 2: calculate the ray parameter from the ray origin to the lines containing the two closest edges to the origin      
			
			var t:Number;//this holds the candidate ray parameter
			var x0:Number,y0:Number,x1:Number,y1:Number;//these hold the coordinates of the cadidate edge/lineseg
			if(dx == 0)
			{
				if(dy == 0)
				{
					//big problem..
					throw new Error("Can't raycast with 0,0!");
					return false;
				}
				
				//the ray is vertical so it can only intersect with y-bounds;
				//prepare lineseg for intersection test
				t = (yval - py)/dy;
				
			}         
			else if(dy == 0)
			{
				//the ray is horizontal so it can only intersect with x-bounds;
				//prepare lineseg for intersection test
				t = (xval - px)/dx;
			}
			else
			{
				//we need to find the potential candidate edge with the greatest ray parameter
				
				var tX:Number = (xval - px) / dx; //calculate ray parameters; note that we've already made sure
				var tY:Number = (yval - py) / dy; //that div-by-0 can't happen here
				
				if(tX < tY)
				{
					//y-edge is candidate;
					//prepare lineseg for intersection test
					x0 = bx - xw;
					x1 = bx + xw;
					y0 = y1 = yval;
					t = tY;
				}
				else
				{
					//x-edge is candidate;
					//prepare lineseg for intersection test
					y0 = by - yw;
					y1 = by + yw;
					x0 = x1 = xval;
					t = tX;
				}
			}
			
			//if the ray parameter of the intersection betwen ray and line is negative, the ray points away from the
			//line and we know there can't be an intersection
			if(0 < t && t < 1)
			{
				outInfo.time = t;
				outInfo.position = new Point( px + t * dx, py + t * dy );
				return true;
			}
			
			return false;
		}
		
		public function getTileBounds(tilePos:Point, fudge:Number = 0.0):Rectangle
		{
			return new Rectangle(Math.floor(tilePos.x) - fudge, Math.floor(tilePos.y) - fudge, 1 + 2*fudge, 1 + 2*fudge);
		}
		
		public override function castRay(start:Point, end:Point, flags:ObjectType, info:RayHitInfo):Boolean
		{
			// Get the bits from the ObjectType.
			var checkMask:int = flags.bits;
			
			// Figure what tile we're on.
			var curTileX:int = Math.floor(start.x), curTileY:int = Math.floor(start.y);
			
			if(!info) info = new RayHitInfo();
			info.position = start; // Default to stopping at the start.
			
			// Figure a normalized delta.
			var deltaNormalized:Point = end.subtract(start).clone()
			if(deltaNormalized.length < 0.01)
			{
				// Early out if we are super short.
				info.time = 1;
				return false;
			}
			
			deltaNormalized.normalize(1.0);
			
			// Sign of ray direction.
			var step:Point = new Point();
			
			// Value of t at which ray crosses first x/y boundary.
			var tMax:Point = new Point();
			
			// Size of a cell in units of t.
			var tDelta:Point = new Point();
			
			if(deltaNormalized.x < 0)
			{
				step.x = -1;
				tMax.x = (curTileX - start.x) / deltaNormalized.x;
				tDelta.x = 1.0 / -deltaNormalized.x;
			}
			else if(0 < deltaNormalized.x)
			{
				step.x = 1;
				tMax.x = ((curTileX + 1) - start.x) / deltaNormalized.x;
				tDelta.x = 1.0 / deltaNormalized.x;
			}
			else
			{
				// We're only going to be walking on y.
				step.x = 0;
				tMax.x = Number.MAX_VALUE;
				tDelta.x = 0;
			}
			
			if(deltaNormalized.y < 0)
			{
				step.y = -1;
				tMax.y = (curTileY - start.y) / deltaNormalized.y;
				tDelta.y = 1.0 / -deltaNormalized.y;
			}
			else if(0 < deltaNormalized.y)
			{
				step.y = 1;
				tMax.y = ((curTileY + 1) - start.y) / deltaNormalized.y;
				tDelta.y = 1.0 / deltaNormalized.y;
			}
			else
			{
				// We're only going to be walking on y.
				step.y = 0;
				tMax.y = Number.MAX_VALUE;
				tDelta.y = 0;
			}
			
			var curPos:Point = new Point(curTileX, curTileY);
			
			// Check our starting tile.
			if(flagMap.getTileFlags(curTileX, curTileY) & checkMask)
			{
				if(getTileBounds(new Point(curTileX, curTileY)).containsPoint(start))
				{
					info.time = 0;
					info.position = start;
					return true;
				}
				
				if(rayVsBox(start, end, getTileBounds(new Point(curTileX, curTileY)), info))
					return true;
			}
			
			// Go as long as we stay in the tilemap.
			var nextPos:Point = new Point();
			
			while( curPos.x >= 0 && curPos.y >= 0 && curPos.x <= (width+1) && curPos.y <= (height+1))
			{
				if(tMax.x < tMax.y)
				{
					// We just cross an edge on X.
					nextPos.x = curPos.x + step.x;
					nextPos.y = curPos.y;
					
					// Check for collision.
					var px:Number = start.x + tMax.x*deltaNormalized.x;
					var py:Number = start.y + tMax.x*deltaNormalized.y;
					
					if(flagMap.getTileFlags(nextPos.x, nextPos.y) & checkMask
						&& rayVsBox(start, end, getTileBounds(nextPos), info))
						return true;
					
					// Tick along.
					tMax.x += tDelta.x;
					curTileX += step.x;
				}
				else
				{
					// We just cross an edge on X.
					nextPos.x = curPos.x;
					nextPos.y = curPos.y + step.y;
					
					// Check for collision.
					px = start.x + tMax.y*deltaNormalized.x;
					py = start.y + tMax.y*deltaNormalized.y;
					
					if(flagMap.getTileFlags(nextPos.x, nextPos.y) & checkMask
						&& rayVsBox(start, end, getTileBounds(nextPos), info))
						return true;
					
					// Tick along.
					tMax.y += tDelta.y;
					curTileY += step.y;
				}
				
				// Update position.
				curPos.x = nextPos.x;
				curPos.y = nextPos.y;
			} 
			
			info.time = 1;
			return false;
		}
		
	}
}