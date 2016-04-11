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
	 * Represents an object layer, parsed from an <objectgroup> object.
	 */
	public class TiledObjectLayer extends TiledLayer {
		/** A vector of all the objects in the layer, in order. */
		public var objects:Vector.<TiledObject>;
		/** A map from type of object, to a vector of all objects of that type. */
		public var typeMap:Object;
		/** A map from name of object, to a single object with that name. */
		public var nameMap:Object;
		
		public function TiledObjectLayer(tmx:XML) {
			super(tmx);
			objects = new Vector.<TiledObject>;
			typeMap = {};
			nameMap = {};
			
			if(tmx) 
			{
				var objectList:XMLList = tmx.object;
				for (var i:uint = 0; i < objectList.length(); i++) {
					var object:TiledObject = new TiledObject(objectList[i]);
					objects.push(object);
					if (object.name) {
						nameMap[object.name] = object;
					}
					if (object.type) {
						(typeMap[object.type] ||= new Vector.<TiledObject>).push(object);
					}
				}
			}
		}
		
		/**
		 * Given an index, returns the object at that position within the layer.
		 * 
		 * @param index The index of the object.
		 * @return The object.
		 */
		public function getObjectByIndex(index:uint):TiledObject {
			return objects[index];
		}
		
		/**
		 * Returns the last object in the layer with the passed name. If the names of your objects
		 * are unique, you can always use this method to find an object by name.
		 * 
		 * @param name The name of the object.
		 * @return The object.
		 */
		public function getObjectByName(name:String):TiledObject {
			return nameMap[name];
		}
		
		/**
		 * Returns a vector of all objects in the layer with the passed type.
		 * 
		 * @param type The type of the objects to find.
		 * @return The vector of objects with the given type.
		 */
		public function getObjectsByType(type:String):Vector.<TiledObject> {
			return typeMap[type];
		}
	}
}
