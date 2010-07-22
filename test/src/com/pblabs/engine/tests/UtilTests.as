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
		
		[Test]
		public function testClamp():void
		{
			Assert.assertEquals(0, PBUtil.clamp(0, 0, 0));
			Assert.assertEquals(.25, PBUtil.clamp(-1, .25, 2));
			Assert.assertEquals(1, PBUtil.clamp(8));
			Assert.assertEquals(1, PBUtil.clamp(1.25));
			Assert.assertEquals(6.25, PBUtil.clamp(8, 0, 6.25));
			Assert.assertEquals(5.1, PBUtil.clamp(5.1, 0.5, 10.5));
		}
		
		[Test]
		public function testCloneArray():void
		{
			var org:Array = [5, 6, "Hello", new Object()];
			var dup:Array = PBUtil.cloneArray(org);
			
			Assert.assertEquals(org.length, dup.length);
			Assert.assertFalse(org == dup);
			
			for ( var i:int=0; i < org.length; i++)
			{
				Assert.assertEquals(org[i], dup[i]);
			}
			
			org = [];
			dup = PBUtil.cloneArray(org);
			
			Assert.assertEquals(org.length, dup.length, 0);
			Assert.assertFalse(org == dup);
		}
		
		[Test]
		public function testUnwrapRadian():void
		{
			Assert.assertEquals(0, PBUtil.unwrapRadian(0));
			Assert.assertEquals(Math.PI, PBUtil.unwrapRadian(Math.PI));
			Assert.assertEquals(-Math.PI, PBUtil.unwrapRadian(-Math.PI));
			Assert.assertEquals(Math.PI/2, PBUtil.unwrapRadian(Math.PI/2));
			Assert.assertEquals(0, PBUtil.unwrapRadian(Math.PI * 2));
			Assert.assertEquals(0, PBUtil.unwrapRadian(Math.PI * -2));
			Assert.assertEquals(Math.PI, PBUtil.unwrapRadian(Math.PI * 3));
		}
		
		[Test]
		public function testUnwrapDegrees():void
		{
			Assert.assertEquals(0, PBUtil.unwrapDegrees(0));
			Assert.assertEquals(0, PBUtil.unwrapDegrees(360));
			Assert.assertEquals(180, PBUtil.unwrapDegrees(180));
			Assert.assertEquals(-180, PBUtil.unwrapDegrees(-180));
			Assert.assertEquals(-90, PBUtil.unwrapDegrees(270));
			Assert.assertEquals(90, PBUtil.unwrapDegrees(810));
			Assert.assertEquals(90, PBUtil.unwrapDegrees(-270));
		}
	}
}