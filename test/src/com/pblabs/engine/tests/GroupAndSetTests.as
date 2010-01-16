package com.pblabs.engine.tests
{
    import com.pblabs.engine.core.PBGroup;
    import com.pblabs.engine.core.PBSet;
    
    import flexunit.framework.Assert;

    public class GroupAndSetTests
    {
        [Test]
        public function groupSetAndObjectJumbo():void
        {
            // Set up test groups.
            var rootGroup:PBGroup = new PBGroup();
            rootGroup.initialize();
            
            var childGroup:PBGroup = new PBGroup();
            childGroup.owningGroup = rootGroup;
            childGroup.initialize();
            
            var grandChildGroup:PBGroup = new PBGroup();
            grandChildGroup.owningGroup = childGroup;
            grandChildGroup.initialize();

            // Set up test sets.
            var setA:PBSet = new PBSet();
            setA.owningGroup = rootGroup;
            setA.initialize();
            
            var setB:PBSet = new PBSet();
            setB.owningGroup = childGroup;
            setB.initialize();
            
            var setC:PBSet = new PBSet();
            setC.owningGroup = grandChildGroup;
            setC.initialize();
            
            // Make them mutual members.
            Assert.assertTrue("could not add set B to A", setA.add(setB));
            Assert.assertTrue("could not add set C to A", setA.add(setC));
            Assert.assertTrue("could not add set A to B", setB.add(setA));
            Assert.assertTrue("could not add set C to B", setB.add(setC));
            Assert.assertTrue("could not add set A to C", setC.add(setA));
            Assert.assertTrue("could not add set B to C", setC.add(setB));

            // Add probe objects all around.
            var curProbe:DestructTester = new DestructTester();
            curProbe.owningGroup = rootGroup;
            curProbe.initialize();
            Assert.assertTrue("could not add probe to setA.", setA.add(curProbe));
            
            curProbe = new DestructTester();
            curProbe.owningGroup = childGroup;
            curProbe.initialize();
            Assert.assertTrue("could not add probe to setB.", setB.add(curProbe));

            curProbe = new DestructTester();
            curProbe.owningGroup = grandChildGroup;
            curProbe.initialize();
            Assert.assertTrue("could not add probe to setC.", setC.add(curProbe));
            
            // Shut it down and see how it behaves.
            DestructTester.destroyCount = 0;
            rootGroup.destroy();
            Assert.assertEquals("rootGroup not empty.", rootGroup.length, 0);
            Assert.assertEquals("childGroup not empty.", childGroup.length, 0);
            Assert.assertEquals("grandChildGroup not empty.", grandChildGroup.length, 0);
            Assert.assertEquals("setA not empty.", setA.length, 0);
            Assert.assertEquals("setB not empty.", setB.length, 0);
            Assert.assertEquals("setC not empty.", setC.length, 0);
            Assert.assertEquals("Not everything was deleted that we expected.", DestructTester.destroyCount, 3);
            
        }
    }
}
import com.pblabs.engine.core.PBObject;

class DestructTester extends PBObject
{
    public static var destroyCount:int = 0;
    
    public override function destroy() : void
    {
        super.destroy();
        destroyCount++;
    }
}