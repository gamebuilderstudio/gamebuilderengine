/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Engine.UnitTests
{
    import PBLabs.Engine.Debug.Logger;
    
    import net.digitalprimates.fluint.tests.TestCase;
    
   /**
    * @private
    */
    public class SanityTests extends TestCase
    {
      public function testNumericalStability():void
      {
         Logger.PrintHeader(null, "Running Numeric Stability Test");
         
         var tickDuration:Number = 1.0 / 32.0;
         var amounts:Array = [0, 0, 0, 0];
         
         for (var i:int = 0; i < 64; i++)
         {
             for (var j:int = 0; j < 4; j++)
                amounts[j] += tickDuration;
         }
         
         for (var k:int = 0; k < 4; k++)
            assertEquals(2.0, amounts[k]);
            
         Logger.PrintFooter(null, "");
      }
      
      public function testMathDiscontinuities():void
      {
         Logger.PrintHeader(null, "Running Math Continuity Test");
         assertEquals(1.0 / 0.0, Number.POSITIVE_INFINITY);
         Logger.PrintFooter(null, "");
      }
    }
}