/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.tests
{
    import com.pblabs.PBEngineTestSuite;
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.core.NameManager;
    import com.pblabs.engine.core.TemplateManager;
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.engine.entity.IEntity;
    import com.pblabs.engine.entity.PropertyReference;
    
    import flash.events.Event;
    
    import flexunit.framework.Assert;
    
    import org.flexunit.async.Async;
    
    /**
     * @private
     */
    public class LevelTests
    {
        private var _testValueAReference:PropertyReference = new PropertyReference("@A.testValue");
        private var _testValueA2Reference:PropertyReference = new PropertyReference("@A2.testValue");
        private var _testComplexXReference:PropertyReference = new PropertyReference("@B.testComplex.x");
        private var _testComplexYReference:PropertyReference = new PropertyReference("@B.testComplex.y");
        
        [Test(async)]
        public function testLevelLoading():void
        {
            Logger.printHeader(null, "Running Level Loading and Instantiating Test");
            
            PBE.templateManager.addEventListener(TemplateManager.LOADED_EVENT, Async.asyncHandler(this, onLevelLoaded, 2000 ));
            //PBE.templateManager.addEventListener(TemplateManager.FAILED_EVENT, Async.asyncHandler(this, onLevelLoadFailed, 2000 ));
            PBE.templateManager.loadFile(PBEngineTestSuite.testLevel);
        }
        
        private function onLevelLoaded(event:Event, passthru:Object):void
        {
            Assert.assertTrue(PBE.templateManager.getXML("TestTemplate1"));
            Assert.assertTrue(PBE.templateManager.getXML("TestTemplate2"));
            Assert.assertTrue(PBE.templateManager.getXML("CyclicalTestTemplate1"));
            Assert.assertTrue(PBE.templateManager.getXML("CyclicalTestTemplate2"));
            Assert.assertTrue(PBE.templateManager.getXML("TestEntity1"));
            Assert.assertTrue(PBE.templateManager.getXML("TestEntity2"));
            Assert.assertTrue(PBE.templateManager.getXML("SimpleGroup"));
            Assert.assertTrue(PBE.templateManager.getXML("ComplexGroup"));
            Assert.assertTrue(PBE.templateManager.getXML("CyclicalGroup1"));
            Assert.assertTrue(PBE.templateManager.getXML("CyclicalGroup2"));
            
            var testTemplate1:IEntity = PBE.templateManager.instantiateEntity("TestTemplate1");
            Assert.assertTrue(testTemplate1);
            Assert.assertEquals(19, testTemplate1.getProperty(_testValueAReference));
            Assert.assertEquals(null, PBE.lookup("TestTemplate1"));
            testTemplate1.destroy();
            
            var testTemplate2:IEntity = PBE.templateManager.instantiateEntity("TestTemplate2");
            Assert.assertTrue(testTemplate2);
            Assert.assertEquals(43, testTemplate2.getProperty(_testValueAReference));
            testTemplate2.destroy();
            
            var cyclicalTemplate:IEntity = PBE.templateManager.instantiateEntity("CyclicalTestTemplate1");
            Assert.assertEquals(null, cyclicalTemplate);
            
            var testEntity1:IEntity = PBE.templateManager.instantiateEntity("TestEntity1");
            Assert.assertTrue(testEntity1);
            Assert.assertEquals(testEntity1, PBE.lookup("TestEntity1"));
            Assert.assertEquals(14, testEntity1.getProperty(_testValueAReference));
            Assert.assertEquals(81.347, testEntity1.getProperty(_testComplexXReference));
            Assert.assertEquals(92.762, testEntity1.getProperty(_testComplexYReference));
            
            var bComponent:TestComponentB = testEntity1.lookupComponentByType(TestComponentB) as TestComponentB;
            Assert.assertEquals(bComponent.getTestValueFromA(), 14);
            
            var testEntity2:IEntity = PBE.templateManager.instantiateEntity("TestEntity2");
            Assert.assertTrue(testEntity2);
            Assert.assertEquals(testEntity2, PBE.lookup("TestEntity2"));
            Assert.assertEquals(638, testEntity2.getProperty(_testValueAReference));
            Assert.assertEquals(1036, testEntity2.getProperty(_testValueA2Reference));
            Assert.assertEquals(8.237, testEntity2.getProperty(_testComplexXReference));
            Assert.assertEquals(12.4, testEntity2.getProperty(_testComplexYReference));
            
            var aComponent:TestComponentA = testEntity2.lookupComponentByName("A") as TestComponentA;
            Assert.assertEquals(testEntity1, aComponent.namedReference);
            Assert.assertTrue(aComponent.instantiatedReference);
            Assert.assertEquals(bComponent, aComponent.componentReference);
            Assert.assertEquals(bComponent, aComponent.namedComponentReference);
            
            testEntity1.destroy();
            testEntity2.destroy();
            
            var testGroup1:Array = PBE.templateManager.instantiateGroup("SimpleGroup");
            Assert.assertEquals(2, testGroup1.length);
            testGroup1[0].destroy();
            testGroup1[1].destroy();
            
            var testGroup2:Array = PBE.templateManager.instantiateGroup("ComplexGroup");
            Assert.assertEquals(3, testGroup2.length);
            testGroup2[0].destroy();
            testGroup2[1].destroy();
            testGroup2[2].destroy();
            
            var cyclicalGroup:Array = PBE.templateManager.instantiateGroup("CyclicalGroup1");
            Assert.assertEquals(null, cyclicalGroup);
            
            PBE.templateManager.unloadFile(PBEngineTestSuite.testLevel);
            Assert.assertTrue(!PBE.templateManager.getXML("TestTemplate1"));
            Assert.assertTrue(!PBE.templateManager.getXML("TestTemplate2"));
            Assert.assertTrue(!PBE.templateManager.getXML("CyclicalTestTemplate1"));
            Assert.assertTrue(!PBE.templateManager.getXML("CyclicalTestTemplate2"));
            Assert.assertTrue(!PBE.templateManager.getXML("TestEntity1"));
            Assert.assertTrue(!PBE.templateManager.getXML("TestEntity2"));
            Assert.assertTrue(!PBE.templateManager.getXML("SimpleGroup"));
            Assert.assertTrue(!PBE.templateManager.getXML("ComplexGroup"));
            Assert.assertTrue(!PBE.templateManager.getXML("CyclicalGroup1"));
            Assert.assertTrue(!PBE.templateManager.getXML("CyclicalGroup2"));
            
            Logger.printFooter(null, "");
        }
        
        private function onLevelLoadFailed(event:Event):void
        {
            Assert.assertTrue(false);
            Logger.printFooter(null, "");
        }
        
    }
}