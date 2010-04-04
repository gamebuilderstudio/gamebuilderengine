/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.rendering2D
{
	import com.pblabs.engine.serialization.Enumerable;
	import com.pblabs.engine.serialization.ISerializable;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;

    /**
     * Helper class for controlling alignment of scene relative to its position.
     */
	public final class SceneAlignment extends Enumerable implements ISerializable
	{
		
		private static var _typeMap:Dictionary = null;
		
		public static const TOP_LEFT:SceneAlignment = new SceneAlignment();
		public static const TOP_RIGHT:SceneAlignment = new SceneAlignment();
		public static const BOTTOM_LEFT:SceneAlignment = new SceneAlignment();
		public static const BOTTOM_RIGHT:SceneAlignment = new SceneAlignment();
		public static const CENTER:SceneAlignment = new SceneAlignment();
		
		public static const DEFAULT_ALIGNMENT:SceneAlignment = CENTER;
		
		// todo add additional alignments
		
		/**
		 * @inheritDoc
		 */
		override public function get typeMap():Dictionary
		{
			if (!_typeMap)
			{
				_typeMap = new Dictionary();
				_typeMap["TOP_LEFT"] = TOP_LEFT;
				_typeMap["TOP_RIGHT"] = TOP_RIGHT;
				_typeMap["BOTTOM_LEFT"] = BOTTOM_LEFT;
				_typeMap["BOTTOM_RIGHT"] = BOTTOM_RIGHT;
				_typeMap["CENTER"] = CENTER;
			}
			
			return _typeMap;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get defaultType():Enumerable
		{
			return CENTER;
		}
		
        /**
         * Given an alignment constant from this class, calculate 
         * @param outPoint
         * @param alignment
         * @param sceneWidth
         * @param sceneHeight
         * 
         */
		public static function calculate(outPoint:Point, alignment:SceneAlignment, sceneWidth:int, sceneHeight:int):void
		{
			switch(alignment)
			{
				case CENTER:
					outPoint.x = sceneWidth * 0.5;
					outPoint.y = sceneHeight * 0.5;
					break;
				case TOP_LEFT:
					outPoint.x = outPoint.y = 0;
					break;
				case TOP_RIGHT:
					outPoint.x = sceneWidth;
					outPoint.y = 0;
					break;
				case BOTTOM_LEFT:
					outPoint.x = 0;
					outPoint.y = sceneHeight;
					break;
				case BOTTOM_RIGHT:
					outPoint.x = sceneWidth;
					outPoint.y = sceneHeight;
					break;
			}
		}
	}
}