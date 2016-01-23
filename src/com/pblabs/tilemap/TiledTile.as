/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2016 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 * Derived from public library by Lee Miller https://github.com/arkeus/as3-tiled-reader
 * License https://github.com/arkeus/as3-tiled-reader/blob/master/LICENSE
 ******************************************************************************/
package com.pblabs.tilemap {
	/**
	 * A class describing a tile. Any tile with special properties, non-default terrain options,
	 * etc, gets a tile representation to hold that information.
	 */
	public class TiledTile {
		/** Constant defining the first entry in a terrain array, the top left corner. */
		public static const TOP_LEFT:uint = 0x0001;
		/** Constant defining the second entry in a terrain array, the top right corner. */
		public static const TOP_RIGHT:uint = 0x0010;
		/** Constant defining the third entry in a terrain array, the bottom left corner. */
		public static const BOTTOM_LEFT:uint = 0x0100;
		/** Constant defining the fourth entry in a terrain array, the bottom right corner. */
		public static const BOTTOM_RIGHT:uint = 0x1000;
		/** A flag defining the top side of a tile, indicated by top left and top right flags being true. */
		public static const TOP:uint = TOP_LEFT | TOP_RIGHT;
		/** A flag defining the left side of a tile, indicated by top left and bottom left flags being true. */
		public static const LEFT:uint = BOTTOM_LEFT | TOP_LEFT;
		/** A flag defining the right side of a tile, indicated by top right and bottom right flags being true. */
		public static const RIGHT:uint = TOP_RIGHT | BOTTOM_RIGHT;
		/** A flag defining the bottom side of a tile, indicated by bottom left and bottom right flags being true. */
		public static const BOTTOM:uint = BOTTOM_LEFT | BOTTOM_RIGHT;
		
		/** A map containing a mapping from the index in the terrain array, to the corner it represents. */
		private static const CORNER_MAP:Vector.<uint> = new <uint>[TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT];
		
		/** The tile id of this tile. */
		public var id:uint;
		/** The raw terrain, in the string format of a,b,c,d. */
		public var rawTerrain:String;
		/** The terrain, a bitmask of TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, and BOTTOM_RIGHT. */
		public var terrain:uint;
		/** The probability of the tile. Used with terrain. */
		public var probability:Number;
		/** Tile properties. */
		public var properties:TiledProperties;
		/** Tile image. */
		//public var image:TiledImage;
		
		public function TiledTile(tmx:XML) {
			id = tmx.@id;
			rawTerrain = tmx.@terrain;
			terrain = csvToTerrain(tmx.@terrain);
			probability = "@probability" in tmx ? tmx.@probability : Number.NaN;
			properties = new TiledProperties(tmx.properties);
			//image = new TiledImage(tmx.image);
		}
		
		/**
		 * Converts a terrain array (in the string format of "a,b,c,d") to an integer representation
		 * with the side flags.
		 * 
		 * Any terrain layer in that corner feeds into this function. For raw tile informat, read from
		 * TiledTile.rawTerrain.
		 * 
		 * @param terrain The terrain array as a string.
		 * @return The integer representation of the sides.
		 */
		private static function csvToTerrain(terrain:String):uint {
			var terrains:Array = terrain.split(","), value:uint = 0x0;
			for (var i:uint = 0; i < terrains.length; i++) {
				if (terrains[i].length > 0) {
					value += 0x1 << i;
				}
			}
			return value;
		}
	}
}
