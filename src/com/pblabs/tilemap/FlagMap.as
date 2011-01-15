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
	/**
	 * Helper class to pack and track information about each tile in a tilemap.
	 * 
	 * Each tile gets 32 bits of space, which we use to store flags and
	 * index information. This avoids a lot of costly allocation, GC
	 * activity, and memory traversal.
	 */
	final public class FlagMap
	{
		public function FlagMap(width:int, height:int)
		{
			_width = width;
			_height = height;
			_flags = new Array(width * height);
		}
		
		public function get width():int
		{
			return _width;
		}
		
		public function get height():int
		{
			return _height;
		}
		
		public function getTileType(x:int, y:int):int
		{
			return _flags[x + _width * y] & TYPE_MASK;                  
		}
		
		public function setTileType(x:int, y:int, type:int):void
		{
			_flags[x + _width * y] = (_flags[x + _width * y] & ~TYPE_MASK) | (type&TYPE_MASK);
		}
		
		public function getTileFlags(x:int, y:int):int
		{
			return (_flags[x + _width * y] & FLAGS_MASK) >> TYPE_OFFSET;
		}
		
		public function setTileFlags(x:int, y:int, flags:int):void
		{
			_flags[x + _width * y] = (_flags[x + _width * y] & ~FLAGS_MASK) | ((flags<<TYPE_OFFSET)&FLAGS_MASK);         
		}
		
		// 12 bits for tile type.
		private static const TYPE_MASK:int = 0xFFF;
		private static const TYPE_OFFSET:int = 12;
		
		// Another 16 bits for the flags. We don't want to use all 32 bits
		// because Flash will tend to kick us out into our own Number on the heap
		// rather than keeping us in an atom.
		private static const FLAGS_MASK:int = 0xFFFF000;
		
		private var _flags:Array;
		private var _width:int, _height:int;
	}
}