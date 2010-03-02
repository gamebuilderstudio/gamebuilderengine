/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package  
{
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.PBE;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author JD
	 */
	public class Hello extends Sprite
	{
		
		public function Hello() 
		{
			PBE.startup(this);
			Logger.print(this, "Hello, World!");
		}
		
	}

}