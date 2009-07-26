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
   import com.pblabs.engine.entity.AllocateEntity;
   import com.pblabs.engine.entity.IEntity;
   import com.pblabs.engine.entity.PropertyReference;
   import com.pblabs.engine.core.TemplateManager;
   import com.pblabs.engine.core.NameManager;
   import com.pblabs.engine.debug.Logger;
   import com.pblabs.engine.unitTestHelper.TestComponentA;
   import com.pblabs.engine.unitTestHelper.TestComponentB;
   
   import flash.geom.Point;
   
   import net.digitalprimates.fluint.tests.TestCase;
   
   /**
    * @private
    */
   public class ComponentTests extends TestCase
   {
      public function testComponents():void
      {
         Logger.printHeader(null, "Running Component Test");
         
         var entity:IEntity = AllocateEntity();
         entity.initialize("TestEntity");
         
         assertEquals(entity, NameManager.instance.lookup("TestEntity"));
         
         var a:TestComponentA = new TestComponentA();
         var b:TestComponentB = new TestComponentB();
         
         entity.addComponent(a, "A");
         assertTrue(a.isRegistered);
         assertFalse(b.isRegistered);
         
         entity.addComponent(b, "B");
         
         assertEquals(a, entity.lookupComponentByName("A"));
         assertEquals(a, entity.lookupComponentByType(TestComponentA));
         assertEquals(null, entity.lookupComponentByName("C"));
         
         entity.removeComponent(a);
         assertTrue(b.isRegistered);
         assertFalse(a.isRegistered);
         assertEquals(null, entity.lookupComponentByName("A"));
         assertEquals(null, entity.lookupComponentByType(TestComponentA));
         
         entity.destroy();
         assertEquals(null, entity.lookupComponentByName("B"));
         assertEquals(null, NameManager.instance.lookup("TestEntity"));
         
         Logger.printFooter(null, "");
      }
      
      public function testProperties():void
      {
         Logger.printHeader(null, "Running Component Property Test");
         
         var entity:IEntity = AllocateEntity();
         entity.initialize("TestEntity");
         
         var a:TestComponentA = new TestComponentA();
         var b:TestComponentB = new TestComponentB();
         entity.addComponent(a, "A");
         entity.addComponent(b, "B");
         
         a.testValue = 126;
         assertEquals(126, entity.getProperty(_testValueReference));
         entity.setProperty(_testValueReference, 834);
         assertEquals(834, a.testValue);
         
         b.TestComplex = new Point(4.593, 81.287);
         assertEquals(4.593, entity.getProperty(_testComplexXReference));
         assertEquals(81.287, entity.getProperty(_testComplexYReference));
         entity.setProperty(_testComplexXReference, 7.239);
         entity.setProperty(_testComplexYReference, 212.923);
         assertEquals(7.239, b.TestComplex.x);
         assertEquals(212.923, b.TestComplex.y);
         
         assertEquals(null, entity.getProperty(_nonexistentReference));
         assertEquals(null, entity.getProperty(_malformedReference));
         
         Logger.printFooter(null, "");
      }
      
      public function testSerialization():void
      {
         Logger.printHeader(null, "Running Component Serialization Test");
         
         TemplateManager.instance.addXML(_testXML, "UnitTestXML", 1);
         var entity:IEntity = TemplateManager.instance.instantiateEntity("XMLTestEntity");
         assertEquals(entity, NameManager.instance.lookup("XMLTestEntity"));
         
         var a:TestComponentA = entity.lookupComponentByName("A") as TestComponentA;
         var b:TestComponentB = entity.lookupComponentByType(TestComponentB) as TestComponentB;
         assertTrue(a);
         assertTrue(b);
         
         assertEquals(7, a.testValue);
         assertEquals(4, b.TestComplex.x);
         assertEquals(9.3, b.TestComplex.y);
         
         entity.destroy();
         
         TemplateManager.instance.removeXML("UnitTestXML");
         assertEquals(null, TemplateManager.instance.getXML("XMLTestEntity"));
         
         Logger.printFooter(null, "");
      }
      
      public function testSerializationCallbacks():void
      {
         Logger.printHeader(null, "Running TemplateManager Entity/Group Callbacks Test");
         
         TemplateManager.instance.registerEntityCallback("TestEntityCallback", entityCallback);
         TemplateManager.instance.registerGroupCallback("TestGroupCallback", groupCallback);
         
         var e:IEntity = TemplateManager.instance.instantiateEntity("TestEntityCallback");
         assertTrue(e);
         assertTrue(e.lookupComponentByType(TestComponentA));
         assertTrue(e.lookupComponentByType(TestComponentB));
         
         var g:Array = TemplateManager.instance.instantiateGroup("TestGroupCallback");
         assertTrue(g.length == 3);
         
         TemplateManager.instance.unregisterEntityCallback("TestEntityCallback");
         TemplateManager.instance.unregisterGroupCallback("TestGroupCallback");
         
         assertTrue(!TemplateManager.instance.instantiateEntity("TestEntityCallback"));
         assertTrue(!TemplateManager.instance.instantiateGroup("TestGroupCallback"));
         
         Logger.printFooter(null, "");
      }
      
      private function entityCallback():IEntity
      {
         var entity:IEntity = AllocateEntity();
         entity.initialize("CallbackCreatedEntity");
         entity.addComponent(new TestComponentA(), "A");
         entity.addComponent(new TestComponentB(), "B");
         return entity;
      }
      
      private function groupCallback():Array
      {
         // Make several entities using the entity callback.
         var res:Array = new Array();
         res.push(entityCallback());
         res.push(entityCallback());
         res.push(entityCallback());
         return res;         
      }
    
      
      private var _testValueReference:PropertyReference = new PropertyReference("@A.TestValue");
      private var _testComplexXReference:PropertyReference = new PropertyReference("@B.TestComplex.x");
      private var _testComplexYReference:PropertyReference = new PropertyReference("@B.TestComplex.y");
      private var _nonexistentReference:PropertyReference = new PropertyReference("@A.Nonexistent");
      private var _malformedReference:PropertyReference = new PropertyReference("Malformed");
      
      private var _testXML:XML = 
         <entity name="XMLTestEntity">
            <component type="com.pblabs.engine.unitTestHelper.TestComponentA" name="A">
               <TestValue>7</TestValue>
            </component>
            <component type="com.pblabs.engine.unitTestHelper.TestComponentB" name="B">
               <TestComplex>
                  <x>4</x>
                  <y>9.3</y>
               </TestComplex>
            </component>
         </entity>;
   }
}
