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
   import PBLabs.Engine.Entity.IEntity;
   import PBLabs.Engine.Entity.IEntityComponent;
   
   /**
    * @private
    */
   public class TestComponentA extends EntityComponent
   {
      public var TestValue:int = 0;
      public var NamedReference:IEntity = null;
      public var InstantiatedReference:IEntity = null;
      public var ComponentReference:TestComponentB = null;
      public var NamedComponentReference:IEntityComponent = null;
   }
}