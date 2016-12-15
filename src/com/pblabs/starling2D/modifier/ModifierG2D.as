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

	public class ModifierG2D extends Object
	{

		// --------------------------------------------------------------
		// public methods
		// --------------------------------------------------------------
		
		public function ModifierG2D()
		{
			super();
		}

		protected var _label : String
		public function get label():String { return _label; }
		public function set label(value:String):void
		{
			_label=value;
		}

		/****************************************************************
		 * This method needs to be overriden to apply modification
		 * to a Starling DisplayObject
		 */		
		public function modify(data:DisplayObject, index:int=0, count:int=1):void
		{
			
		}

		// --------------------------------------------------------------
		// private and protected methods
		// --------------------------------------------------------------
				
	}
}