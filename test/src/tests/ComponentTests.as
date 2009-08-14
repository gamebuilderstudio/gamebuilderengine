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
   import com.pblabs.engine.core.NameManager;
   import com.pblabs.engine.core.TemplateManager;
   import com.pblabs.engine.debug.Logger;
   import com.pblabs.engine.entity.IEntity;
   import com.pblabs.engine.entity.PropertyReference;
   import com.pblabs.engine.entity.allocateEntity;
   
   import flash.geom.Point;
   
   import flexunit.framework.Assert;
   
   import tests.helpers.TestComponentA;
   import tests.helpers.TestComponentB;
   
   /**
    * @private
    */
   public class ComponentTests
   {
   [Test]
      public function testComponents():void
      {
         Logger.printHeader(null, "Running Component Test");
         
         var entity:IEntity = allocateEntity();
         entity.initialize("TestEntity");
         
         Assert.assertEquals(entity, NameManager.instance.lookup("TestEntity"));
         
         var a:TestComponentA = new TestComponentA();
         var b:TestComponentB = new TestComponentB();
         
         entity.addComponent(a, "A");
         Assert.assertTrue(a.isRegistered);
         Assert.assertFalse(b.isRegistered);
         
         entity.addComponent(b, "B");
         
         Assert.assertEquals(a, entity.lookupComponentByName("A"));
         Assert.assertEquals(a, entity.lookupComponentByType(TestComponentA));
         Assert.assertEquals(null, entity.lookupComponentByName("C"));
         
         entity.removeComponent(a);
         Assert.assertTrue(b.isRegistered);
         Assert.assertFalse(a.isRegistered);
         Assert.assertEquals(null, entity.lookupComponentByName("A"));
         Assert.assertEquals(null, entity.lookupComponentByType(TestComponentA));
         
         entity.destroy();
         Assert.assertEquals(null, entity.lookupComponentByName("B"));
         Assert.assertEquals(null, NameManager.instance.lookup("TestEntity"));
         
         Logger.printFooter(null, "");
      }
      
   [Test]
      public function testProperties():void
      {
         Logger.printHeader(null, "Running Component Property Test");
         
         var entity:IEntity = allocateEntity();
         entity.initialize("TestEntity");
         
         var a:TestComponentA = new TestComponentA();
         var b:TestComponentB = new TestComponentB();
         entity.addComponent(a, "A");
         entity.addComponent(b, "B");
         
         a.testValue = 126;
         Assert.assertEquals(126, entity.getProperty(_testValueReference));
         entity.setProperty(_testValueReference, 834);
         Assert.assertEquals(834, a.testValue);
         
         b.testComplex = new Point(4.593, 81.287);
         Assert.assertEquals(4.593, entity.getProperty(_testComplexXReference));
         Assert.assertEquals(81.287, entity.getProperty(_testComplexYReference));
         entity.setProperty(_testComplexXReference, 7.239);
         entity.setProperty(_testComplexYReference, 212.923);
         Assert.assertEquals(7.239, b.testComplex.x);
         Assert.assertEquals(212.923, b.testComplex.y);
         
         Assert.assertEquals(null, entity.getProperty(_nonexistentReference));
         Assert.assertEquals(null, entity.getProperty(_malformedReference));
         
         Logger.printFooter(null, "");
      }
      
   [Test]
      public function testSerialization():void
      {
         Logger.printHeader(null, "Running Component Serialization Test");
         
         TemplateManager.instance.addXML(_testXML, "UnitTestXML", 1);
         var entity:IEntity = TemplateManager.instance.instantiateEntity("XMLTestEntity");
         Assert.assertNotNull(entity, "Should have gotten something back from TemplateManager!");
         Assert.assertEquals(entity, NameManager.instance.lookup("XMLTestEntity"));
         
         var a:TestComponentA = entity.lookupComponentByName("A") as TestComponentA;
         var b:TestComponentB = entity.lookupComponentByType(TestComponentB) as TestComponentB;
         Assert.assertTrue(a);
         Assert.assertTrue(b);
         
         Assert.assertEquals(7, a.testValue);
         Assert.assertEquals(4, b.testComplex.x);
         Assert.assertEquals(9.3, b.testComplex.y);
         
         entity.destroy();
         
         TemplateManager.instance.removeXML("UnitTestXML");
         Assert.assertEquals(null, TemplateManager.instance.getXML("XMLTestEntity"));
         
         Logger.printFooter(null, "");
      }
      
   [Test]
      public function testSerializationCallbacks():void
      {
         Logger.printHeader(null, "Running TemplateManager Entity/Group Callbacks Test");
         
         TemplateManager.instance.registerEntityCallback("TestEntityCallback", entityCallback);
         TemplateManager.instance.registerGroupCallback("TestGroupCallback", groupCallback);
         
         var e:IEntity = TemplateManager.instance.instantiateEntity("TestEntityCallback");
         Assert.assertTrue(e);
         Assert.assertTrue(e.lookupComponentByType(TestComponentA));
         Assert.assertTrue(e.lookupComponentByType(TestComponentB));
         
         var g:Array = TemplateManager.instance.instantiateGroup("TestGroupCallback");
         Assert.assertTrue(g.length == 3);
         
         TemplateManager.instance.unregisterEntityCallback("TestEntityCallback");
         TemplateManager.instance.unregisterGroupCallback("TestGroupCallback");
         
         Assert.assertTrue(!TemplateManager.instance.instantiateEntity("TestEntityCallback"));
         Assert.assertTrue(!TemplateManager.instance.instantiateGroup("TestGroupCallback"));
         
         Logger.printFooter(null, "");
      }
      
      private function entityCallback():IEntity
      {
         var entity:IEntity = allocateEntity();
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
    
      
      private var _testValueReference:PropertyReference = new PropertyReference("@A.testValue");
      private var _testComplexXReference:PropertyReference = new PropertyReference("@B.testComplex.x");
      private var _testComplexYReference:PropertyReference = new PropertyReference("@B.testComplex.y");
      private var _nonexistentReference:PropertyReference = new PropertyReference("@A.nonexistent");
      private var _malformedReference:PropertyReference = new PropertyReference("malformed");
      
      private var _testXML:XML = 
         <entity name="XMLTestEntity">
            <component type="tests.helpers.TestComponentA" name="A">
               <testValue>7</testValue>
            </component>
            <component type="tests.helpers.TestComponentB" name="B">
               <testComplex>
                  <x>4</x>
                  <y>9.3</y>
               </testComplex>
            </component>
         </entity>;
   }
}
