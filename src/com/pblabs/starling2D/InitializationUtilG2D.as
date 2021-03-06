/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2012 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.starling2D
{
	import org.osflash.signals.Signal;

	public class InitializationUtilG2D
	{
		public static const disposed : Signal = new Signal();
		public static const initializeRenderers : Signal = new Signal();
		
		public function InitializationUtilG2D()
		{
		}
	}
}