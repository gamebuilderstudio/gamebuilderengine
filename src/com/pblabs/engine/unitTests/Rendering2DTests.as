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
   import net.digitalprimates.fluint.tests.TestCase;

   /**
    * @private
    */
   public class Rendering2DTests extends TestCase
   {
      public function testBoxVsBox():void
      {
         Logger.printHeader(null, "Running BoxVsBox Test");

      	 var basicSpatialManager2D:BasicSpatialManager2D = new BasicSpatialManager2D();
      	 
      	 try
      	 { 
      	   basicSpatialManager2D.boxVsBoxTest();
      	 }
      	 catch(e:Error)
      	 {      		 
      	   Logger.print(null,e.message);
      	   assertTrue(false);   	
      	 }
      	       	  
       	 Logger.printFooter(null, "");
       	       		      	
      }      
   }
}