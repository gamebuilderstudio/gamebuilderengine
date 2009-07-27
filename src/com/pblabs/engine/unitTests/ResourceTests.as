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
   
   import net.digitalprimates.fluint.tests.TestCase;
   
   /**
    * @private
    */
   public class ResourceTests extends TestCase
   {
      public function testResourceLoad():void
      {
         Logger.printHeader(null, "Running Resource Load Test");
         Logger.printFooter(null, "");
      }
      
      public function testReferenceCounting():void
      {
         Logger.printHeader(null, "Running Resource Reference Count Test");
         Logger.printFooter(null, "");
      }
   }
}