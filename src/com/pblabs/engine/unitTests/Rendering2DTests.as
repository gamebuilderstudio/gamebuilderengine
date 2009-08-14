/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.unitTests
{
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.rendering2D.BasicSpatialManager2D;

	import flash.geom.Rectangle;

	import net.digitalprimates.fluint.tests.TestCase;

	/**
	 * @private
	 */
	public class Rendering2DTests extends TestCase
	{
		public function testBoxVsBox():void
		{
			Logger.printHeader(null, "Running BoxVsBox Test");

			var m:BasicSpatialManager2D=new BasicSpatialManager2D();

			//tall and skinny vs. short and fat. queue comedy.
			Logger.print(null, "Testing tall and skinny vs. short and fat");
			var box1:Rectangle=new Rectangle(0, 45, 100, 10);
			var box2:Rectangle=new Rectangle(45, 0, 10, 100);

			assertTrue(m.boxVsBox(box1, box2));
			assertTrue(m.boxVsBox(box2, box1));

			//fully overlapping
			Logger.print(null, "Testing fully overlapping");
			box1=new Rectangle(0, 0, 100, 100);
			box2=new Rectangle(0, 0, 100, 100);

			assertTrue(m.boxVsBox(box1, box2));
			assertTrue(m.boxVsBox(box2, box1));

			//containing each other
			Logger.print(null, "Testing containing each other");
			box1=new Rectangle(0, 0, 100, 100);
			box2=new Rectangle(45, 45, 10, 10);

			assertTrue(m.boxVsBox(box1, box2));
			assertTrue(m.boxVsBox(box2, box1));

			//topLeft
			Logger.print(null, "Testing top left corner overlap");
			box2=new Rectangle(45, 45, 100, 100);

			assertTrue(m.boxVsBox(box1, box2));
			assertTrue(m.boxVsBox(box2, box1));

			//topRight
			Logger.print(null, "Testing top right corner overlap");
			box2=new Rectangle(-45, 45, 100, 100);

			assertTrue(m.boxVsBox(box1, box2));
			assertTrue(m.boxVsBox(box2, box1));

			//bottomLeft
			Logger.print(null, "Testing bottom left corner overlap");
			box2=new Rectangle(45, -45, 100, 100);

			assertTrue(m.boxVsBox(box1, box2));
			assertTrue(m.boxVsBox(box2, box1));

			//bottomRight
			Logger.print(null, "Testing bottom right corner overlap");
			box2=new Rectangle(-45, -45, 100, 100);

			assertTrue(m.boxVsBox(box1, box2));
			assertTrue(m.boxVsBox(box2, box1));

			//negative test
			Logger.print(null, "Testing negative condition");
			box1=new Rectangle(0, 0, 100, 100);
			box2=new Rectangle(-101, -101, 100, 100);

			assertFalse(m.boxVsBox(box1, box2));
			assertFalse(m.boxVsBox(box2, box1));

			Logger.printFooter(null, "");
		}
	}
}