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
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.core.NameManager;
    import com.pblabs.engine.core.TemplateManager;
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.engine.entity.IEntity;
    import com.pblabs.engine.entity.PropertyReference;
    import com.pblabs.engine.entity.allocateEntity;
    
    import flash.geom.Point;
    
    import flexunit.framework.Assert;

    /**
     * @private
     */
    public class ComponentTests
    {
        private var _testValueReference:PropertyReference = new PropertyReference("@A.testValue");
        private var _testComplexXReference:PropertyReference = new PropertyReference("@B.testComplex.x");
        private var _testComplexYReference:PropertyReference = new PropertyReference("@B.testComplex.y");
        private var _nonexistentReference:PropertyReference = new PropertyReference("@A.nonexistent");
        private var _malformedReference:PropertyReference = new PropertyReference("malformed");

        private var _testXML:XML = 
            <entity name="XMLTestEntity">
                <component type="com.pblabs.engine.tests.TestComponentA" name="A">
                    <testValue>7</testValue>
                </component>
                <component type="com.pblabs.engine.tests.TestComponentB" name="B">
                    <testComplex>
                        <x>4</x>
                        <y>9.3</y>
                    </testComplex>
                </component>
            </entity>;

        [Test]
        public function testComponents():void
        {
            Logger.printHeader(null, "Running Component Test");

            var entity:IEntity = allocateEntity();
            entity.initialize("TestEntity");

            Assert.assertEquals(entity, PBE.lookup("TestEntity"));

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
            Assert.assertEquals(null, PBE.lookup("TestEntity"));

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

            PBE.templateManager.addXML(_testXML, "UnitTestXML", 1);
            var entity:IEntity = PBE.templateManager.instantiateEntity("XMLTestEntity");
            Assert.assertNotNull(entity, "Should have gotten something back from TemplateManager!");
            var lookedupEntity:IEntity = PBE.lookup("XMLTestEntity") as IEntity;
            Assert.assertEquals(entity, lookedupEntity);

            var a:TestComponentA = entity.lookupComponentByName("A") as TestComponentA;
            var b:TestComponentB = entity.lookupComponentByType(TestComponentB) as TestComponentB;
            Assert.assertTrue(a);
            Assert.assertTrue(b);

            Assert.assertEquals(7, a.testValue);
            Assert.assertEquals(4, b.testComplex.x);
            Assert.assertEquals(9.3, b.testComplex.y);

            entity.destroy();

            PBE.templateManager.removeXML("UnitTestXML");
            Assert.assertEquals(null, PBE.templateManager.getXML("XMLTestEntity"));

            Logger.printFooter(null, "");
        }

        [Test]
        public function testSerializationCallbacks():void
        {
            Logger.printHeader(null, "Running TemplateManager Entity/Group Callbacks Test");

            PBE.templateManager.registerEntityCallback("TestEntityCallback", entityCallback);
            PBE.templateManager.registerGroupCallback("TestGroupCallback", groupCallback);

            var e:IEntity = PBE.templateManager.instantiateEntity("TestEntityCallback");
            Assert.assertTrue(e);
            Assert.assertTrue(e.lookupComponentByType(TestComponentA));
            Assert.assertTrue(e.lookupComponentByType(TestComponentB));

            var g:Array = PBE.templateManager.instantiateGroup("TestGroupCallback");
            Assert.assertTrue(g.length == 3);

            PBE.templateManager.unregisterEntityCallback("TestEntityCallback");
            PBE.templateManager.unregisterGroupCallback("TestGroupCallback");

            Assert.assertTrue(!PBE.templateManager.instantiateEntity("TestEntityCallback"));
            Assert.assertTrue(!PBE.templateManager.instantiateGroup("TestGroupCallback"));

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

    }
}
