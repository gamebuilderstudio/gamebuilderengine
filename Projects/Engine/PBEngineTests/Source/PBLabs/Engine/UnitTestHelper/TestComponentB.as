/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Engine.UnitTestHelper
{
   import PBLabs.Engine.Entity.EntityComponent;
   import PBLabs.Engine.Entity.PropertyReference;
   
   import flash.geom.Point;
   
   /**
    * @private
    */
   public class TestComponentB extends EntityComponent
   {
      public var TestComplex:Point = null;
      
      public var ATestValueReference:PropertyReference = new PropertyReference();
      
      public function GetTestValueFromA():int
      {
         return Owner.GetProperty(ATestValueReference);
      }
   }
}