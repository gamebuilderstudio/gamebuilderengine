/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.unitTestHelper
{
   import com.pblabs.engine.entity.EntityComponent;
   import com.pblabs.engine.entity.PropertyReference;
   
   import flash.geom.Point;
   
   /**
    * @private
    */
   public class TestComponentB extends EntityComponent
   {
      public var TestComplex:Point = null;
      
      public var ATestValueReference:PropertyReference = new PropertyReference();
      
      public function getTestValueFromA():int
      {
         return owner.getProperty(ATestValueReference);
      }
   }
}