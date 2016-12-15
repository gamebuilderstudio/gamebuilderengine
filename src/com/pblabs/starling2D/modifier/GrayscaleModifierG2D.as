/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2012 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.starling2D.modifier
{
	import starling.display.DisplayObject;
	import starling.filters.ColorMatrixFilter;
	import starling.filters.FilterChain;

	public class GrayscaleModifierG2D extends ModifierG2D
	{
		private var _filter:ColorMatrixFilter;
		
		public function GrayscaleModifierG2D()
		{
			super();
		}
		
		public override function modify(object:DisplayObject, index:int = 0 , count:int=1):void
		{
			// colorize this specific frame bitmap
			var matrix:Array = [];
			matrix=matrix.concat([0.3086, 0.6094, 0.0820,0,0]);// red
			matrix=matrix.concat([0.3086, 0.6094, 0.0820,0,0]);// green
			matrix=matrix.concat([0.3086, 0.6094, 0.0820,0,0]);// blue
			matrix=matrix.concat([0,0,0,1,0]);// alpha
			
			
			if(object.filter && object.filter is FilterChain)
			{
				_filter = new ColorMatrixFilter();
				_filter.concatValues(0.3086, 0.6094, 0.0820,0,0,
									 0.3086, 0.6094, 0.0820,0,0,
									 0.3086, 0.6094, 0.0820,0,0,
									 0,  0,  0,  1,   0);
				
				(object.filter as FilterChain).addFilter(_filter);
			}
		}
		
	}
}