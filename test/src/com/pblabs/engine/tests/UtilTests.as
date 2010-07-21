/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.tests
{
	import com.pblabs.engine.PBUtil;
	
	import org.flexunit.Assert;
	
	/**
	 * @private
	 */
	public class UtilTests
	{
		
		[Test]
		public function testRadiansToDegrees():void
		{
			Assert.assertEquals(-180, PBUtil.getDegreesFromRadians(Math.PI * -1));
			Assert.assertEquals(360, PBUtil.getDegreesFromRadians(Math.PI * 2));
			Assert.assertEquals(90, PBUtil.getDegreesFromRadians(Math.PI / 2));
			Assert.assertEquals(180, PBUtil.getDegreesFromRadians(Math.PI));
			Assert.assertEquals(0, PBUtil.getDegreesFromRadians(0));
		}
		
		[Test]
		public function testDegreesToRadians():void
		{
			Assert.assertEquals(Math.PI * -1, PBUtil.getRadiansFromDegrees(-180));
			Assert.assertEquals(Math.PI * 2, PBUtil.getRadiansFromDegrees(360));
			Assert.assertEquals(Math.PI / 2, PBUtil.getRadiansFromDegrees(90));
			Assert.assertEquals(Math.PI, PBUtil.getRadiansFromDegrees(180));
			Assert.assertEquals(0, PBUtil.getRadiansFromDegrees(0));
		}
	}
}