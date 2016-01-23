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
	 * Represents a single tile layer within a map.
	 */
	public class TiledTileLayer extends TiledLayer {
		/** The encoding used on the layer data. */
		public var encoding:String;
		/** The compression used on the layer data. */
		public var compression:String;
		/** The parsed layer data, uncompressed and unencoded. */
		public var data:Array;

		public function TiledTileLayer(tmx:XML) {
			super(tmx);
			
			if(tmx){
				var dataNode:XML = tmx.data[0];
				encoding = "@encoding" in dataNode ? dataNode.@encoding : null;
				compression = "@compression" in dataNode ? dataNode.@compression : null;
				data = TiledUtils.stringToTileData(dataNode.text(), width, encoding, compression);
			}
		}
	}
}
