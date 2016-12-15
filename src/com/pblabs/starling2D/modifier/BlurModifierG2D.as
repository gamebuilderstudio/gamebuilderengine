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
	import starling.filters.BlurFilter;
	import starling.filters.FilterChain;
	
	public class BlurModifierG2D extends ModifierG2D
	{
		/** The blur factor in x-direction.
		 *  The number of required passes will be <code>Math.ceil(value)</code>. */
		public function get blurX():Number { return _blurX; }
		public function set blurX(value:Number):void
		{
			_blurX = value;
			if(_filter) _filter.blurX = _blurX;
		}
		
		/** The blur factor in y-direction.
		 *  The number of required passes will be <code>Math.ceil(value)</code>. */
		public function get blurY():Number { return _blurY; }
		public function set blurY(value:Number):void
		{
			_blurY = value;
			if(_filter) _filter.blurY = _blurY;
		}
		
		/** @private */
		public function get quality():Number { return _quality; }
		public function set quality(value:Number):void
		{
			_quality = value;
			if(_filter) _filter.resolution = _quality;
		}
		
		private var _blurX:Number = 0;
		private var _blurY:Number = 0;
		private var _quality:Number = 1;
		private var _filter : BlurFilter;
		
		public function BlurModifierG2D(blurX:Number=6, blurY:Number=6,  quality:int=1)
		{
			this.blurX = blurX;
			this.blurY = blurY;
			this.quality = quality;
			super();
		}
		
		public override function modify(object:DisplayObject, index:int = 0 , count:int=1):void
		{	
			if(object.filter && object.filter is FilterChain)
			{
				_filter = new BlurFilter(blurX, blurY, quality);
				(object.filter as FilterChain).addFilter(_filter);
			}
		}
	}
}