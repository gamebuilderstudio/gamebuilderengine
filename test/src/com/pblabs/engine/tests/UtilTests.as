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
	import org.hamcrest.object.nullValue;
	
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
		
		[Test]
		public function testRadianShortDelta():void
		{
			Assert.assertEquals(0, PBUtil.getRadianShortDelta(Math.PI, Math.PI * 3));
			Assert.assertEquals(0, PBUtil.getRadianShortDelta(Math.PI/2, Math.PI/2));
			Assert.assertEquals(-1 * Math.PI, PBUtil.getRadianShortDelta(Math.PI, Math.PI * 2));
			Assert.assertEquals(0, PBUtil.getRadianShortDelta(-1 * Math.PI, Math.PI * 3));
			Assert.assertEquals(-1 * Math.PI/2, PBUtil.getRadianShortDelta(-3 * Math.PI, Math.PI/2));
		}
		
		[Test]
		public function testDegreesShortDelta():void
		{
			Assert.assertEquals(0, PBUtil.getDegreesShortDelta(90, 450));
			Assert.assertEquals(180, PBUtil.getDegreesShortDelta(-90, 810));
			Assert.assertEquals(1, PBUtil.getDegreesShortDelta(90, 91));
			Assert.assertEquals(135, PBUtil.getDegreesShortDelta(45, -180));
			Assert.assertEquals(-90, PBUtil.getDegreesShortDelta(0, 990));
			Assert.assertEquals(-180, PBUtil.getDegreesShortDelta(1080, -180));
			Assert.assertEquals(0, PBUtil.getDegreesShortDelta(-180, 180));
		}
		
		[Test]
		public function testBitCountRange():void
		{
			Assert.assertEquals(0, PBUtil.getBitCountForRange(0));
			Assert.assertEquals(1, PBUtil.getBitCountForRange(1));
			Assert.assertEquals(1, PBUtil.getBitCountForRange(2));
			Assert.assertEquals(4, PBUtil.getBitCountForRange(15));
			Assert.assertEquals(8, PBUtil.getBitCountForRange(200));
			Assert.assertEquals(10, PBUtil.getBitCountForRange(1023));
			Assert.assertEquals(10, PBUtil.getBitCountForRange(1024));
			Assert.assertEquals(11, PBUtil.getBitCountForRange(1025));
		}
		
		// Not sure how much more testing that this I can do...  The bias part is hard to test
		[Test]
		public function testBiasedPick():void
		{
			Assert.assertEquals(5, PBUtil.pickWithBias(5, 100, -1));
			Assert.assertEquals(100, PBUtil.pickWithBias(5, 100, 1));
			Assert.assertEquals(-50, PBUtil.pickWithBias(-50, 100, -1));
			Assert.assertEquals(-100, PBUtil.pickWithBias(-500, -100, 1));
			var val:int = PBUtil.pickWithBias(5, 100, .6);
			Assert.assertTrue(val >= 5);
			Assert.assertTrue(val <= 100);
		}
		
		[Test]
		public function testDuckAssign():void
		{
			var dest:DuckTypeTestClass = new DuckTypeTestClass();
			var testObj:Object = {'foo':'bar'};
			
			PBUtil.duckAssign({'string':'Some String', 'number':5, 'integer':10, 'unsigned':11}, dest, false);
			Assert.assertEquals('Some String', dest.string);
			Assert.assertEquals(5, dest.number);
			Assert.assertEquals(10, dest.integer);
			Assert.assertEquals(11, dest.unsigned);
			
			PBUtil.duckAssign({'string':'Some String', 'number':5, 'integer':10, 'unsigned':11}, dest, true);
			Assert.assertEquals('Some String', dest.string);
			Assert.assertEquals(5, dest.number);
			Assert.assertEquals(10, dest.integer);
			Assert.assertEquals(11, dest.unsigned);
			
			PBUtil.duckAssign({'string':'Some String', 'number':5, 'integer':10, 'unsigned':11, 'object':testObj}, dest, false);
			Assert.assertEquals('Some String', dest.string);
			Assert.assertEquals(5, dest.number);
			Assert.assertEquals(10, dest.integer);
			Assert.assertEquals(11, dest.unsigned);
			Assert.assertEquals(dest.object, testObj);
			
			PBUtil.duckAssign({'string':'Some String', 'number':5, 'integer':10, 'unsigned':11, 'object':testObj}, dest, true);
			Assert.assertEquals('Some String', dest.string);
			Assert.assertEquals(5, dest.number);
			Assert.assertEquals(10, dest.integer);
			Assert.assertEquals(11, dest.unsigned);
			Assert.assertEquals(dest.object, testObj);

			PBUtil.duckAssign({'string':'Some String', 'number':5, 'integer':10, 'unsigned':11, 'object':testObj, 'undefined':'something'}, dest, false);
			Assert.assertEquals('Some String', dest.string);
			Assert.assertEquals(5, dest.number);
			Assert.assertEquals(10, dest.integer);
			Assert.assertEquals(11, dest.unsigned);

			var errorThrown:Boolean = false;
			try {
				PBUtil.duckAssign({'string':'Some String', 'number':5, 'integer':10, 'unsigned':11, 'object':testObj, 'undefined':'something'}, dest, true);
			} catch (e:Error) {
				errorThrown = true;
			}
			Assert.assertTrue(errorThrown);
			
			PBUtil.duckAssign({'string':5, 'number':'Twenty', 'integer':10, 'unsigned':11}, dest, true);
			Assert.assertEquals('5', dest.string);
			Assert.assertTrue(isNaN(dest.number));
			Assert.assertEquals(10, dest.integer);
			Assert.assertEquals(11, dest.unsigned);
		}
	}
}

class DuckTypeTestClass
{
	public var string:String;
	public var number:Number;
	public var integer:int;
	public var unsigned:uint;
	public var object:Object;
}