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
   import com.pblabs.engine.entity.IEntity;
   import com.pblabs.engine.entity.PropertyReference;
   import com.pblabs.engine.core.TemplateManager;
   import com.pblabs.engine.core.NameManager;
   import com.pblabs.engine.debug.Logger;
   import tests.helpers.TestComponentA;
   import tests.helpers.TestComponentB;
   
   import flash.events.Event;
   
   import net.digitalprimates.fluint.tests.TestCase;
   
   /**
    * @private
    */
   public class LevelTests extends TestCase
   {
      public function testLevelLoading():void
      {
         Logger.printHeader(null, "Running Level Loading and Instantiating Test");
         
         TemplateManager.instance.addEventListener(TemplateManager.LOADED_EVENT, asyncHandler( onLevelLoaded, 2000 ));
         //TemplateManager.instance.addEventListener(TemplateManager.FAILED_EVENT, asyncHandler( onLevelLoadFailed, 2000 ));
         TemplateManager.instance.loadFile(PBEngineTestSuite.testLevel);
      }
      
      private function onLevelLoaded(event:Event, passthru:Object):void
      {
         assertTrue(TemplateManager.instance.getXML("TestTemplate1"));
         assertTrue(TemplateManager.instance.getXML("TestTemplate2"));
         assertTrue(TemplateManager.instance.getXML("CyclicalTestTemplate1"));
         assertTrue(TemplateManager.instance.getXML("CyclicalTestTemplate2"));
         assertTrue(TemplateManager.instance.getXML("TestEntity1"));
         assertTrue(TemplateManager.instance.getXML("TestEntity2"));
         assertTrue(TemplateManager.instance.getXML("SimpleGroup"));
         assertTrue(TemplateManager.instance.getXML("ComplexGroup"));
         assertTrue(TemplateManager.instance.getXML("CyclicalGroup1"));
         assertTrue(TemplateManager.instance.getXML("CyclicalGroup2"));
         
         var testTemplate1:IEntity = TemplateManager.instance.instantiateEntity("TestTemplate1");
         assertTrue(testTemplate1);
         assertEquals(19, testTemplate1.getProperty(_testValueAReference));
         assertEquals(null, NameManager.instance.lookup("TestTemplate1"));
         testTemplate1.destroy();
         
         var testTemplate2:IEntity = TemplateManager.instance.instantiateEntity("TestTemplate2");
         assertTrue(testTemplate2);
         assertEquals(43, testTemplate2.getProperty(_testValueAReference));
         testTemplate2.destroy();
         
         var cyclicalTemplate:IEntity = TemplateManager.instance.instantiateEntity("CyclicalTestTemplate1");
         assertEquals(null, cyclicalTemplate);
         
         var testEntity1:IEntity = TemplateManager.instance.instantiateEntity("TestEntity1");
         assertTrue(testEntity1);
         assertEquals(testEntity1, NameManager.instance.lookup("TestEntity1"));
         assertEquals(14, testEntity1.getProperty(_testValueAReference));
         assertEquals(81.347, testEntity1.getProperty(_testComplexXReference));
         assertEquals(92.762, testEntity1.getProperty(_testComplexYReference));
         
         var bComponent:TestComponentB = testEntity1.lookupComponentByType(TestComponentB) as TestComponentB;
         assertEquals(bComponent.getTestValueFromA(), 14);
         
         var testEntity2:IEntity = TemplateManager.instance.instantiateEntity("TestEntity2");
         assertTrue(testEntity2);
         assertEquals(testEntity2, NameManager.instance.lookup("TestEntity2"));
         assertEquals(638, testEntity2.getProperty(_testValueAReference));
         assertEquals(1036, testEntity2.getProperty(_testValueA2Reference));
         assertEquals(8.237, testEntity2.getProperty(_testComplexXReference));
         assertEquals(12.4, testEntity2.getProperty(_testComplexYReference));
         
         var aComponent:TestComponentA = testEntity2.lookupComponentByName("A") as TestComponentA;
         assertEquals(testEntity1, aComponent.namedReference);
         assertTrue(aComponent.instantiatedReference);
         assertEquals(bComponent, aComponent.componentReference);
         assertEquals(bComponent, aComponent.namedComponentReference);
         
         testEntity1.destroy();
         testEntity2.destroy();
         
         var testGroup1:Array = TemplateManager.instance.instantiateGroup("SimpleGroup");
         assertEquals(2, testGroup1.length);
         testGroup1[0].destroy();
         testGroup1[1].destroy();
         
         var testGroup2:Array = TemplateManager.instance.instantiateGroup("ComplexGroup");
         assertEquals(3, testGroup2.length);
         testGroup2[0].destroy();
         testGroup2[1].destroy();
         testGroup2[2].destroy();
         
         var cyclicalGroup:Array = TemplateManager.instance.instantiateGroup("CyclicalGroup1");
         assertEquals(null, cyclicalGroup);
         
         TemplateManager.instance.unloadFile(PBEngineTestSuite.testLevel);
         assertTrue(!TemplateManager.instance.getXML("TestTemplate1"));
         assertTrue(!TemplateManager.instance.getXML("TestTemplate2"));
         assertTrue(!TemplateManager.instance.getXML("CyclicalTestTemplate1"));
         assertTrue(!TemplateManager.instance.getXML("CyclicalTestTemplate2"));
         assertTrue(!TemplateManager.instance.getXML("TestEntity1"));
         assertTrue(!TemplateManager.instance.getXML("TestEntity2"));
         assertTrue(!TemplateManager.instance.getXML("SimpleGroup"));
         assertTrue(!TemplateManager.instance.getXML("ComplexGroup"));
         assertTrue(!TemplateManager.instance.getXML("CyclicalGroup1"));
         assertTrue(!TemplateManager.instance.getXML("CyclicalGroup2"));
         
         Logger.printFooter(null, "");
      }
      
      private function onLevelLoadFailed(event:Event):void
      {
         assertTrue(false);
         Logger.printFooter(null, "");
      }
      
      private var _testValueAReference:PropertyReference = new PropertyReference("@A.testValue");
      private var _testValueA2Reference:PropertyReference = new PropertyReference("@A2.testValue");
      private var _testComplexXReference:PropertyReference = new PropertyReference("@B.testComplex.x");
      private var _testComplexYReference:PropertyReference = new PropertyReference("@B.testComplex.y");
   }
}