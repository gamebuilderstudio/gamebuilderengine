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
	import flash.geom.Point;

	/**
	 * A container holding properties for a single tileset within the map.
	 */
	public class TiledTileset {
		/** The first global tile id in the tileset. */
		public var firstGid:uint;
		/** The name of the tilset. */
		public var name:String;
		/** The maximum width of tiles in this tileset. */
		public var tileWidth:uint;
		/** The maximum height of tiles in this tileset. */
		public var tileHeight:uint;
		/** The spacing, in pixels, between the tiles in this tileset. */
		public var spacing:uint;
		/** The margin around the tiles in this tileset. */
		public var margin:uint;
		/** The offset, in pixels, for the tiles in this tileset. */
		public var tileOffset:Point;
		/** The properties of the tileset. */
		public var properties:TiledProperties;
		/** The tileset image. */
		public var image : TiledImage;
		/** A map from terrain name to terrains contained within this tileset. */
		public var terrain:Object;
		/** A map from gid to tile for all the non-standard tiles in the tileset. */
		public var tiles:Object;

		public function TiledTileset(tmx:XML) {
			firstGid = tmx.@firstgid;
			name = tmx.@name;
			tileWidth = tmx.@tilewidth;
			tileHeight = tmx.@tileheight;
			spacing = "@spacing" in tmx ? tmx.@spacing : 0;
			margin = "@margin" in tmx ? tmx.@margin : 0;

			var offset:XMLList = tmx.tileoffset;
			tileOffset = offset.length() == 1 ? new Point(offset.@x, offset.@y) : new Point;

			image = new TiledImage(tmx.image);
			terrain = loadTerrain(tmx.terraintypes);
			tiles = loadTiles(tmx.tile);
		}

		/**
		 * Given a tileset, loads all the terrains from the terraintypes object.
		 *
		 * @param tmx The terraintypes object.
		 * @return The map from terrain name to terrain.
		 */
		private static function loadTerrain(tmx:XMLList):Object {
			var terrain:Object = {};

			for (var i:uint = 0; i < tmx.terrain.length(); i++) {
				var node:TiledTerrain = new TiledTerrain(tmx.terrain[i]);
				terrain[node.name] = node;
			}

			return terrain;
		}

		/**
		 * Given a list of tiles, builds a map from gid to tile.
		 *
		 * @param tmx The XMLList of <tile> objects.
		 * @return The map from gid to tiles.
		 */
		private static function loadTiles(tmx:XMLList):Object {
			var tiles:Object = {};

			for (var i:uint = 0; i < tmx.length(); i++) {
				var node:TiledTile = new TiledTile(tmx[i]);
				tiles[node.id] = node;
			}

			return tiles;
		}
	}
}
