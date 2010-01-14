/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs
{
	import com.pblabs.engine.tests.ComponentTests;
	import com.pblabs.engine.tests.EntityRegistrationTests;
	import com.pblabs.engine.tests.GroupAndSetTests;
	import com.pblabs.engine.tests.InputTests;
	import com.pblabs.engine.tests.LevelTests;
	import com.pblabs.engine.tests.ProcessTests;
	import com.pblabs.engine.tests.ResourceTests;
	import com.pblabs.engine.tests.SanityTests;
	import com.pblabs.rendering2D.tests.Rendering2DTests;

	/**
	 * @private
	 */
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class PBEngineTestSuite
	{
		public static var testLevel:String="";

		//to specify a test suite to run, just put it here as a public variable
		public var sanityTests:SanityTests;
		public var componentTests:ComponentTests;
		public var levelTests:LevelTests;
		public var resourceTests:ResourceTests;
		//public var processTests:ProcessTests;
		public var rendering2DTests:Rendering2DTests;
		public var inputTests:InputTests;
        public var entityRegistrationTests:EntityRegistrationTests;
        public var groupAndSetTests:GroupAndSetTests;
	}
}