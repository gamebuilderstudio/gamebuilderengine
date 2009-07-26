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
   import com.pblabs.engine.unitTests.*;
   
   import net.digitalprimates.fluint.tests.TestSuite;
   
   /**
    * @private
    */
   public class PBEngineTestSuite extends TestSuite
   {
      static public function get testLevel():String
      {
         return _testLevel;
      }
      
      static private var _testLevel:String = "";
      
      public function PBEngineTestSuite(testLevel:String)
      {
         _testLevel = testLevel;
         
         addTestCase(new SanityTests());
         addTestCase(new ComponentTests());
         addTestCase(new LevelTests());
         addTestCase(new ResourceTests());
         addTestCase(new ProcessTests());
         addTestCase(new InputTests());
      }
   }
}