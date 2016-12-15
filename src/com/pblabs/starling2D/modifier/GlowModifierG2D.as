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
	import starling.filters.FilterChain;
	import starling.filters.GlowFilter;
	
	public class GlowModifierG2D extends ModifierG2D
	{
		// --------------------------------------------------------------
		// public getter/setter functions
		// --------------------------------------------------------------
		/** The color value**/
		public function get color():uint { return _color; }
		public function set color(data:uint):void
		{
			_color = data;
			if(_filter) _filter.color = _color;
		}
		
		/** The alpha value**/
		public function get alpha():Number { return _alpha; }
		public function set alpha(data:Number):void
		{
			_alpha = data;
			if(_filter) _filter.alpha = _alpha;
		}

		/** The blurX value**/
		public function get blurX():Number { return _blurX; }
		public function set blurX(data:Number):void
		{
			_blurX = data;
			if(_filter) _filter.blur = _blurX;
		}

		/** The blurY value**/
		public function get blurY():Number { return _blurY; }
		public function set blurY(data:Number):void
		{
			_blurY = data;
			if(_filter) _filter.blur = _blurY;
		}

		/** The strength value**/
		public function get strength():Number { return _strength; }
		public function set strength(data:Number):void
		{
			_strength = data;
			if(_filter) _filter.resolution = _strength;
		}

		/** The quality value**/
		public function get quality():int { return _quality; }
		public function set quality(data:int):void
		{
			_quality = data;
		}

		private var _color:uint = 0xff0000;
		private var _alpha:Number = 1;
		private var _blurX:Number = 6;
		private var _blurY:Number = 6;
		private var _strength:Number = 2;
		private var _quality:int = 1;
		
		private var _filter : GlowFilter;
		// --------------------------------------------------------------
		// public methods
		// --------------------------------------------------------------
		
		public function GlowModifierG2D(color:uint, alpha:Number=1, blurX:Number=6, blurY:Number=6,  strength:Number=2, quality:int=1)
		{
			this._color = color;
			this._alpha = alpha;
			this._blurX = blurX;
			this._blurY = blurY;
			this._strength = strength;
			this._quality = quality;
			// call inherited contructor
			super();
		}
		
		public override function modify(object:DisplayObject, index:int = 0 , count:int=1):void
		{
			if(object.filter && object.filter is FilterChain)
			{
				_filter = new GlowFilter(_color, _alpha, _blurX*_blurY, _strength);
				(object.filter as FilterChain).addFilter(_filter);
			}
		}
		
		// --------------------------------------------------------------
		// private and protected properties
		// --------------------------------------------------------------
				
	}
}