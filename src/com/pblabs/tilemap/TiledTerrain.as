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
	 * A container for the a terrain set within a tileset.
	 */
	public class TiledTerrain {
		/** The name of the terrain. */
		public var name:String;
		/** The tile representing the terrain, -1 if none. */
		public var tile:int;
		/** The terrain properties. */
		public var properties:TiledProperties;
		
		public function TiledTerrain(terrain:XML) {
			name = terrain.@name;
			tile = terrain.@tile;
			properties = new TiledProperties(terrain.properties);
		}
	}
}
