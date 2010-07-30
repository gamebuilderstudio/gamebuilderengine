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

import flash.display.DisplayObject;

import flash.display.Shape;
import flash.geom.Matrix;

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
			var values:Array = [
				{'expect': -180, 'input': Math.PI * -1},
				{'expect': 360, 'input': Math.PI * 2},
				{'expect': 90, 'input': Math.PI / 2},
				{'expect': 180, 'input': Math.PI},
				{'expect': 0, 'input': 0}
			];

			for ( var i:int = 0; i < values.length; i++)
				Assert.assertEquals(values[i].expect, PBUtil.getDegreesFromRadians(values[i].input));
		}
		
		[Test]
		public function testDegreesToRadians():void
		{
			var values:Array = [
				{'expect': Math.PI * -1, 'input': -180},
				{'expect': Math.PI * 2, 'input': 360},
				{'expect': Math.PI / 2, 'input': 90},
				{'expect': Math.PI, 'input': 180},
				{'expect': 0, 'input': 0}
			];
			
			for (var i:int = 0; i < values.length; i++)
				Assert.assertEquals(values[i].expect, PBUtil.getRadiansFromDegrees(values[i].input));
		}
		
		[Test]
		public function testClamp():void
		{
			var values:Array = [
				{'expect': 0, 'val': 0, 'min':0 , 'max':0},
				{'expect': .25, 'val': -1, 'min':.25 , 'max':2},
				{'expect': 6.25, 'val': 8, 'min':0 , 'max':6.25},
				{'expect': 5.1, 'val': 5.1, 'min':0.5 , 'max':10.5}
			];
			
			for (var i:int = 0; i < values.length; i++)
				Assert.assertEquals(values[i].expect, PBUtil.clamp(values[i].val, values[i].min, values[i].max));
			
			values = [
				{'expect': 0, 'input': 0},
				{'expect': 1, 'input': 8},
				{'expect': .5, 'input': .5},
				{'expect': 0, 'input': -.5}
			];
			
			for (i = 0; i < values.length; i++)
				Assert.assertEquals(values[i].expect, PBUtil.clamp(values[i].input));
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
			var values:Array = [
				{'expect': 0, 'input': 0},
				{'expect': Math.PI, 'input': Math.PI},
				{'expect': -Math.PI, 'input': Math.PI * -1},
				{'expect': Math.PI/2, 'input': Math.PI / 2},
				{'expect': 0, 'input': Math.PI * 2},
				{'expect': 0, 'input': Math.PI * -2},
				{'expect': Math.PI, 'input': Math.PI * 3}
			];
			
			for (var i:int = 0; i < values.length; i++)
				Assert.assertEquals(values[i].expect, PBUtil.unwrapRadian(values[i].input));
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
		
		[Test]
		public function testXYLength():void
		{
			var values:Array = [
				{'expect':13, 'x':5, 'y':12},
				{'expect':5, 'x':3, 'y':4}
			];
			
			for (var i:int = 0; i < values.length; i++)
				Assert.assertEquals(values[i].expect, PBUtil.xyLength(values[i].x, values[i].y));
		}
		
		[Test]
		public function testEscapeHTML():void
		{
			var values:Array = [
				{'expect':'Foo &amp; Bar', 'input':'Foo & Bar'},
				{'expect':'&lt; &gt; &apos; &quot;', 'input':'< > \' "'},
				{'expect':'&amp;amp;', 'input':'&amp;'},
				{'expect':'', 'input':''}
			];
			
			for (var i:int = 0; i < values.length; i++)
				Assert.assertEquals(values[i].expect, PBUtil.escapeHTMLText(values[i].input));
	 	}

        [Test]
        public function testStringToBool():void
        {
            var values:Array = [
                {'expect': true, 'input': 'TRUE'},
                {'expect': true, 'input': 'true'},
                {'expect': true, 'input': 't'},
                {'expect': true, 'input': 'T'},
                {'expect': true, 'input': '1'},
                {'expect': true, 'input': 'tRuE'},
                {'expect': false, 'input': 'FALSE'},
                {'expect': false, 'input': 'false'},
                {'expect': false, 'input': 'F'},
                {'expect': false, 'input': 'f'},
                {'expect': false, 'input': '0'},
                {'expect': false, 'input': 'fAlSe'}
            ];

			for (var i:int = 0; i < values.length; i++)
				Assert.assertStrictlyEquals(values[i].expect, PBUtil.stringToBoolean(values[i].input));
        }

        [Test]
        public function testCapitalize():void
        {
            var values:Array = [
                {'expect': 'This', 'input': 'this'},
                {'expect': '', 'input': ''},
                {'expect': 'This', 'input': 'This'},
                {'expect': 'Other', 'input': 'other'},
                {'expect': '1234', 'input': '1234'},
                {'expect': ' how is this', 'input': ' how is this'}
            ];

			for (var i:int = 0; i < values.length; i++)
				Assert.assertEquals(values[i].expect, PBUtil.capitalize(values[i].input));
        }

        [Test]
        public function testTrim():void
        {
            var values:Array = [
                {'expect': 'foo', 'input':'  foo  ', 'ch':' '},
                {'expect': 'bar', 'input':'fffbarfff', 'ch':'f'},
                {'expect': '', 'input':'    ', 'ch':' '},
                {'expect': '', 'input':'', 'ch':' '},
                {'expect': 'foo', 'input':'foo', 'ch':' '},
                {'expect': 'foo', 'input':'foo  ', 'ch':' '},
                {'expect': 'foo', 'input':'  foo', 'ch':' '}
            ];

            for (var i:int = 0; i < values.length; i++)
                Assert.assertEquals(values[i].expect, PBUtil.trim(values[i].input, values[i].ch));
        }

        [Test]
        public function testTrimFront():void
        {
            var values:Array = [
                {'expect': 'foo  ', 'input':'  foo  ', 'ch':' '},
                {'expect': 'barfff', 'input':'fffbarfff', 'ch':'f'},
                {'expect': '', 'input':'    ', 'ch':' '},
                {'expect': '', 'input':'', 'ch':' '},
                {'expect': 'foo', 'input':'foo', 'ch':' '},
                {'expect': 'foo  ', 'input':'foo  ', 'ch':' '},
                {'expect': 'foo', 'input':'  foo', 'ch':' '}
            ];

            for (var i:int = 0; i < values.length; i++)
                Assert.assertEquals(values[i].expect, PBUtil.trimFront(values[i].input, values[i].ch));
        }

        [Test]
        public function testTrimBack():void
        {
            var values:Array = [
                {'expect': '  foo', 'input':'  foo  ', 'ch':' '},
                {'expect': 'fffbar', 'input':'fffbarfff', 'ch':'f'},
                {'expect': '', 'input':'    ', 'ch':' '},
                {'expect': '', 'input':'', 'ch':' '},
                {'expect': 'foo', 'input':'foo', 'ch':' '},
                {'expect': 'foo', 'input':'foo  ', 'ch':' '},
                {'expect': '  foo', 'input':'  foo', 'ch':' '}
            ];

            for (var i:int = 0; i < values.length; i++)
                Assert.assertEquals(values[i].expect, PBUtil.trimBack(values[i].input, values[i].ch));
        }

        [Test]
        public function testStringToCharacter():void
        {
            var values:Array = [
                {'expect': 'f', 'input':'foobar'},
                {'expect': ' ', 'input':'      '},
                {'expect': '', 'input':''},
                {'expect': '1', 'input':'123456'},
                {'expect': '@', 'input':'@'},
                {'expect': '!', 'input':'!220adsf'}
            ];

            for (var i:int = 0; i < values.length; i++)
                Assert.assertEquals(values[i].expect, PBUtil.stringToCharacter(values[i].input));
        }

        [Test]
        public function testGetFileExtension():void
        {
            var values:Array = [
                {'expect':'exe', 'input':'some.file.exe'},
                {'expect':'', 'input':'some_file'},
                {'expect':'', 'input':''},
                {'expect':'thisIsSomeFile', 'input':'a.thisIsSomeFile'},
                {'expect':'htaccess', 'input':'.htaccess'}
            ];

            for (var i:int = 0; i < values.length; i++)
                Assert.assertEquals(values[i].expect, PBUtil.getFileExtension(values[i].input));
        }

        [Test]
        public function testFlipDisplayObject():void
        {
            var a:Shape = new Shape();
            var b:Shape = new Shape();
            var c:Shape = new Shape();
            a.x = b.x = c.x = 10;
            a.y = b.y = c.y = 15;

            a.graphics.beginFill(0x000000);
            a.graphics.lineStyle(0x000000, 0x000000);
            a.graphics.drawRect(0, 0, 20, 30);
            a.graphics.endFill();
            b.graphics.beginFill(0x000000);
            b.graphics.lineStyle(0x000000, 0x000000);
            b.graphics.drawRect(0, 0, 20, 30);
            b.graphics.endFill();
            c.graphics.beginFill(0x000000);
            c.graphics.lineStyle(0x000000, 0x000000);
            c.graphics.drawRect(0, 0, 20, 30);
            c.graphics.endFill();

            var aM:Matrix = a.transform.matrix;
            var bM:Matrix = b.transform.matrix;
            var cM:Matrix = c.transform.matrix;
            
            bM.a = 1;
            bM.d = 1;
            b.transform.matrix = bM;
            
            cM.a = 1.5;
            cM.d = .5;
            cM.tx = 15;
            cM.ty = 25;
            c.transform.matrix = cM;

            PBUtil.flipDisplayObject(a, PBUtil.FLIP_HORIZONTAL);
            PBUtil.flipDisplayObject(b, PBUtil.FLIP_VERTICAL);
            PBUtil.flipDisplayObject(c, PBUtil.FLIP_HORIZONTAL);
            PBUtil.flipDisplayObject(c, PBUtil.FLIP_VERTICAL);

            var aNM:Matrix = a.transform.matrix;
            var bNM:Matrix = b.transform.matrix;
            var cNM:Matrix = c.transform.matrix;

            Assert.assertEquals(-1, aNM.a);
            Assert.assertEquals(30, aNM.tx);
            Assert.assertEquals(-1, bNM.d);
            Assert.assertEquals(45, bNM.ty);
            Assert.assertEquals(-1.5, cNM.a);
            Assert.assertEquals(45, cNM.tx);
            Assert.assertEquals(-.5, cNM.d);
            Assert.assertEquals(40, cNM.ty);
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