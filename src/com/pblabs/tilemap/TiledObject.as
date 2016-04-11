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
	 * Represents a single <object> within an <objectgroup> in the map.
	 */
	public class TiledObject {
		public static const RECTANGLE:uint = 0;
		public static const ELLIPSE:uint = 1;
		public static const POLYGON:uint = 2;
		public static const POLYLINE:uint = 3;
		
		/** The name of the object. If unique, can be used to find the object by name. */
		public var name:String;
		/** The type of the object. Can find all objects of a given type using this value. */
		public var type:String;
		/** The global tile id of the object, if the object is a tile object. Otherwise, 0. */
		public var gid:uint;
		/** The x value of the object. */
		public var x:int;
		/** The y value of the object. */
		public var y:int;
		/** The width of the object. */
		public var width:uint;
		/** The height of the object. */
		public var height:uint;
		/** Whether or not this object is visible. */
		public var visible:Boolean;
		/** The properties of the object. */
		public var properties:TiledProperties;
		/** The shape of the object, represented by TiledObject constants. */
		public var shape:uint;
		/** A vector of points, if the object is a polygon or polyline. */
		public var points:Vector.<Point>;
		
		public function TiledObject(tmx:XML) {
			name = "@name" in tmx ? tmx.@name : null;
			type = "@type" in tmx ? tmx.@type : null;
			gid = "@gid" in tmx ? tmx.@gid : 0;
			x = tmx.@x;
			y = tmx.@y;
			width = "@width" in tmx ? tmx.@width : 0;
			height = "@height" in tmx ? tmx.@height : 0;
			visible = !("@visible" in tmx && tmx.@visible == "0");
			properties = new TiledProperties(tmx.properties);
			shape = RECTANGLE;
			
			if (tmx.ellipse.length() > 0) {
				shape = ELLIPSE;
			} else if (tmx.polygon.length() > 0) {
				shape = POLYGON;
				populatePoints(tmx.polygon.@points);
			} else if (tmx.polyline.length() > 0) {
				shape = POLYLINE;
				populatePoints(tmx.polyline.@points);
			}
		}
		
		/**
		 * Given a space separate list of comma separate points, converts them into a
		 * vector of points.
		 */
		private function populatePoints(pointString:String):void {
			points = new Vector.<Point>;
			var pointArray:Array = pointString.split(" ");
			for (var i:uint = 0; i < pointArray.length; i++) {
				var ps:Array = pointArray[i].split(",");
				if (ps.length != 2) {
					throw new ArgumentError("Invalid poly point: " + pointArray[i]);
				}
				points.push(new Point(parseFloat(ps[0]), parseFloat(ps[1])));
			}
		}
	}
}