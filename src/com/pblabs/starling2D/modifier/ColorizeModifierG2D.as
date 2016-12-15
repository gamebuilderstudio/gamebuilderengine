/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.starling2D.modifier
{
	import starling.display.DisplayObject;
	import starling.filters.ColorMatrixFilter;
	import starling.filters.FilterChain;

	public class ColorizeModifierG2D extends ModifierG2D
	{
		/** The red color **/
		public function get red():Array { return _red; }
		public function set red(data:Array):void
		{
			_red = data;
			applyFilterValues();
		}
		
		/** The green color **/
		public function get green():Array { return _green; }
		public function set green(data:Array):void
		{
			_green = data;
			applyFilterValues();
		}

		/** The blue color **/
		public function get blue():Array { return _blue; }
		public function set blue(data:Array):void
		{
			_blue = data;
			applyFilterValues();
		}

		/** The alpha value **/
		public function get alpha():Array { return _alpha; }
		public function set alpha(data:Array):void
		{
			_alpha = data;
			applyFilterValues();
		}

		private var _red:Array = null;
		private var _green:Array = null;
		private var _blue:Array = null;
		private var _alpha:Array = null;
		
		private var _filter:ColorMatrixFilter;

		// --------------------------------------------------------------
		// public methods
		// --------------------------------------------------------------
		
		public function ColorizeModifierG2D(red:Array, green:Array, blue:Array, alpha:Array)
		{
			this._red = red;
			this._green = green;
			this._blue = blue;
			this._alpha = alpha;
			// call inherited contructor
			super();
		}
		
		
		public override function modify(object:DisplayObject, index:int = 0 , count:int=1):void
		{
			if(!_red || !_green || !_blue) return;
			
			
			
			if(object.filter && object.filter is FilterChain)
			{
				_filter = new ColorMatrixFilter();
				applyFilterValues();
				// colorize this specific frame bitmap
				(object.filter as FilterChain).addFilter(_filter);
			}
		}
		
		// --------------------------------------------------------------
		// private and protected properties
		// --------------------------------------------------------------
		private function applyFilterValues():void
		{
			if(!_filter) return;
			
			var colorMatrix:Vector.<Number> = new Vector.<Number>();
			colorMatrix=colorMatrix.concat(new <Number>[_red[0], _red[1], _red[2], _red[3], _red[4]]);// red
			colorMatrix=colorMatrix.concat(new <Number>[_green[0], _green[1], _green[2], _green[3], _green[4]]);// green
			colorMatrix=colorMatrix.concat(new <Number>[_blue[0], _blue[1], _blue[2], _blue[3], _blue[4]]);// blue
			colorMatrix=colorMatrix.concat(new <Number>[_alpha[0], _alpha[1], _alpha[2], _alpha[3], _alpha[4]]);// alpha
			
			_filter.concat(colorMatrix);
		}
	}
}