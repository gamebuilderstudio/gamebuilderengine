/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package tests
{
    import com.pblabs.engine.debug.Logger;
    
    import flexunit.framework.Assert;
    
   /**
    * @private
    */
    public class SanityTests
    {
      [Test]
      public function testNumericalStability():void
      {
         Logger.printHeader(null, "Running Numeric Stability Test");
         
         var tickDuration:Number = 1.0 / 32.0;
         var amounts:Array = [0, 0, 0, 0];
         
         for (var i:int = 0; i < 64; i++)
         {
             for (var j:int = 0; j < 4; j++)
                amounts[j] += tickDuration;
         }
         
         for (var k:int = 0; k < 4; k++)
            Assert.assertEquals(2.0, amounts[k]);
            
         Logger.printFooter(null, "");
      }
      
      [Test]
      public function testMathDiscontinuities():void
      {
         Logger.printHeader(null, "Running Math Continuity Test");
         Assert.assertEquals(1.0 / 0.0, Number.POSITIVE_INFINITY);
         Logger.printFooter(null, "");
      }
    }
}