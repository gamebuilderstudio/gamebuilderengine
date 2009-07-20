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
   import PBLabs.Engine.Entity.AllocateEntity;
   import PBLabs.Engine.Entity.IEntity;
   import PBLabs.Engine.Entity.PropertyReference;
   import PBLabs.Engine.Core.TemplateManager;
   import PBLabs.Engine.Core.NameManager;
   import PBLabs.Engine.Debug.Logger;
   import PBLabs.Engine.UnitTestHelper.TestComponentA;
   import PBLabs.Engine.UnitTestHelper.TestComponentB;
   
   import flash.geom.Point;
   
   import net.digitalprimates.fluint.tests.TestCase;
   
   /**
    * @private
    */
   public class ComponentTests extends TestCase
   {
      public function testComponents():void
      {
         Logger.PrintHeader(null, "Running Component Test");
         
         var entity:IEntity = AllocateEntity();
         entity.Initialize("TestEntity");
         
         assertEquals(entity, NameManager.Instance.Lookup("TestEntity"));
         
         var a:TestComponentA = new TestComponentA();
         var b:TestComponentB = new TestComponentB();
         
         entity.AddComponent(a, "A");
         assertTrue(a.IsRegistered);
         assertFalse(b.IsRegistered);
         
         entity.AddComponent(b, "B");
         
         assertEquals(a, entity.LookupComponentByName("A"));
         assertEquals(a, entity.LookupComponentByType(TestComponentA));
         assertEquals(null, entity.LookupComponentByName("C"));
         
         entity.RemoveComponent(a);
         assertTrue(b.IsRegistered);
         assertFalse(a.IsRegistered);
         assertEquals(null, entity.LookupComponentByName("A"));
         assertEquals(null, entity.LookupComponentByType(TestComponentA));
         
         entity.Destroy();
         assertEquals(null, entity.LookupComponentByName("B"));
         assertEquals(null, NameManager.Instance.Lookup("TestEntity"));
         
         Logger.PrintFooter(null, "");
      }
      
      public function testProperties():void
      {
         Logger.PrintHeader(null, "Running Component Property Test");
         
         var entity:IEntity = AllocateEntity();
         entity.Initialize("TestEntity");
         
         var a:TestComponentA = new TestComponentA();
         var b:TestComponentB = new TestComponentB();
         entity.AddComponent(a, "A");
         entity.AddComponent(b, "B");
         
         a.TestValue = 126;
         assertEquals(126, entity.GetProperty(_testValueReference));
         entity.SetProperty(_testValueReference, 834);
         assertEquals(834, a.TestValue);
         
         b.TestComplex = new Point(4.593, 81.287);
         assertEquals(4.593, entity.GetProperty(_testComplexXReference));
         assertEquals(81.287, entity.GetProperty(_testComplexYReference));
         entity.SetProperty(_testComplexXReference, 7.239);
         entity.SetProperty(_testComplexYReference, 212.923);
         assertEquals(7.239, b.TestComplex.x);
         assertEquals(212.923, b.TestComplex.y);
         
         assertEquals(null, entity.GetProperty(_nonexistentReference));
         assertEquals(null, entity.GetProperty(_malformedReference));
         
         Logger.PrintFooter(null, "");
      }
      
      public function testSerialization():void
      {
         Logger.PrintHeader(null, "Running Component Serialization Test");
         
         TemplateManager.Instance.AddXML(_testXML, "UnitTestXML", 1);
         var entity:IEntity = TemplateManager.Instance.InstantiateEntity("XMLTestEntity");
         assertEquals(entity, NameManager.Instance.Lookup("XMLTestEntity"));
         
         var a:TestComponentA = entity.LookupComponentByName("A") as TestComponentA;
         var b:TestComponentB = entity.LookupComponentByType(TestComponentB) as TestComponentB;
         assertTrue(a != null);
         assertTrue(b != null);
         
         assertEquals(7, a.TestValue);
         assertEquals(4, b.TestComplex.x);
         assertEquals(9.3, b.TestComplex.y);
         
         entity.Destroy();
         
         TemplateManager.Instance.RemoveXML("UnitTestXML");
         assertEquals(null, TemplateManager.Instance.GetXML("XMLTestEntity"));
         
         Logger.PrintFooter(null, "");
      }
      
      public function testSerializationCallbacks():void
      {
         Logger.PrintHeader(null, "Running TemplateManager Entity/Group Callbacks Test");
         
         TemplateManager.Instance.RegisterEntityCallback("TestEntityCallback", _entityCallback);
         TemplateManager.Instance.RegisterGroupCallback("TestGroupCallback", _groupCallback);
         
         var e:IEntity = TemplateManager.Instance.InstantiateEntity("TestEntityCallback");
         assertTrue(e != null);
         assertTrue(e.LookupComponentByType(TestComponentA) != null);
         assertTrue(e.LookupComponentByType(TestComponentB) != null);
         
         var g:Array = TemplateManager.Instance.InstantiateGroup("TestGroupCallback");
         assertTrue(g.length == 3);
         
         TemplateManager.Instance.UnregisterEntityCallback("TestEntityCallback");
         TemplateManager.Instance.UnregisterGroupCallback("TestGroupCallback");
         
         assertTrue(TemplateManager.Instance.InstantiateEntity("TestEntityCallback") == null);
         assertTrue(TemplateManager.Instance.InstantiateGroup("TestGroupCallback") == null);
         
         Logger.PrintFooter(null, "");
      }
      
      private function _entityCallback():IEntity
      {
         var entity:IEntity = AllocateEntity();
         entity.Initialize("CallbackCreatedEntity");
         entity.AddComponent(new TestComponentA(), "A");
         entity.AddComponent(new TestComponentB(), "B");
         return entity;
      }
      
      private function _groupCallback():Array
      {
         // Make several entities using the entity callback.
         var res:Array = new Array();
         res.push(_entityCallback());
         res.push(_entityCallback());
         res.push(_entityCallback());
         return res;         
      }
    
      
      private var _testValueReference:PropertyReference = new PropertyReference("@A.TestValue");
      private var _testComplexXReference:PropertyReference = new PropertyReference("@B.TestComplex.x");
      private var _testComplexYReference:PropertyReference = new PropertyReference("@B.TestComplex.y");
      private var _nonexistentReference:PropertyReference = new PropertyReference("@A.Nonexistent");
      private var _malformedReference:PropertyReference = new PropertyReference("Malformed");
      
      private var _testXML:XML = 
         <entity name="XMLTestEntity">
            <component type="PBLabs.Engine.UnitTestHelper.TestComponentA" name="A">
               <TestValue>7</TestValue>
            </component>
            <component type="PBLabs.Engine.UnitTestHelper.TestComponentB" name="B">
               <TestComplex>
                  <x>4</x>
                  <y>9.3</y>
               </TestComplex>
            </component>
         </entity>;
   }
}
