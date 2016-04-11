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
package com.pblabs.tilemap
{
	
	/**
	 * Basic spatial class that implements a tilemap. Exists physically, cannot
	 * be rotated or moved (currently), and supports raycasts.
	 */
	public class TiledMap
	{
		/** The TMX format version, always 1.0 currently. */
		public var version:String;
		/** Map orientation, one of: orthogonal, isometric, stagerred. */
		public var orientation:String;
		/** The width of the map in tiles. */
		public var width:uint;
		/** The height of the map in tiles. */
		public var height:uint;
		/** The width of a tile in pixels. */
		public var tileWidth:uint;
		/** The height of a tile in pixels. */
		public var tileHeight:uint;
		/** The background color of the map. */
		public var backgroundColor:uint;
		/** Properties of the map. */
		public var properties:TiledProperties;
		/** A container containing information on the tilesets of the map. */
		public var tilesets:Vector.<TiledTileset>;
		/** A container containing information on the layers of the map. */
		public var layers:TiledLayers;
		
		public function TiledMap(tmx:XML):void {
			version = "@version" in tmx ? tmx.@version : "?";
			orientation = "@orientation" in tmx ? tmx.@orientation : "othogonal";
			width = tmx.@width;
			height = tmx.@height;
			tileWidth = tmx.@tilewidth;
			tileHeight = tmx.@tileheight;
			backgroundColor = "@backgroundcolor" in tmx ? TiledUtils.colorStringToUint(tmx.@backgroundcolor) : 0x0;
			properties = new TiledProperties(tmx.properties);
			
			tilesets = new Vector.<TiledTileset>();
			for (var i:uint = 0; i < tmx.tileset.length(); i++) {
				tilesets.push( new TiledTileset(tmx.tileset[i]) );
			}
			parseLayers(tmx);
		}
		
		/**
		 * Parses the layers of the map, building the TiledLayers container containing information
		 * on each parsed layer. The order of the layers is kept intact, from bottom to top.
		 * 
		 * @param tmx The map object.
		 */
		private function parseLayers(tmx:XML):void {
			layers = new TiledLayers;
			
			// Parse all children, since for some reason layer and objectgroup aren't grouped easily, even though the ordering
			// between them can be very important. WHY BJORN, WHY?
			var elements:XMLList = tmx.children();
			for (var i:uint = 0; i < elements.length(); i++) {
				var name:Object = (elements[i] as XML).name();
				if (name.localName == "layer") {
					layers.addLayer(new TiledTileLayer(elements[i]));
				} else if (name.localName == "objectgroup") {
					layers.addLayer(new TiledObjectLayer(elements[i]));
				} else if (name.localName == "imagelayer") {
					//layers.addLayer(new TiledImageLayer(elements[i]));
				}
			}
		}		
	}
}