package com.pblabs.engine.tests
{
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.entity.IEntity;
    
    import flexunit.framework.Assert;

    /**
     * Tests relating to adding/removing components from entities.
     * 
     * This came out of a discussion at http://pushbuttonengine.com/forum/viewtopic.php?f=9&t=502
     */
    public class EntityRegistrationTests
    {
        [Test]
        public function testRecursiveAddDelete():void
        {
            // Recursively add components to an entity, then initialize it so onAdd is called.
            var e:IEntity = PBE.allocateEntity();
            e.addComponent(new RecursiveAddRemoveTestComponent(), "addRoot");
            e.initialize(null);
            
            // Validate only one is present by the time initialize finishes.
            Assert.assertNull("Initial add/remove failed.", e.lookupComponentByName("addRoot"));
            for(var i:int=100; i>1; i--)
                Assert.assertNull("Recursive add/remove failed at #" + i + ".", e.lookupComponentByName("c" + i + "addRemove"));
            Assert.assertNotNull("Final add/remove failed.", e.lookupComponentByName("c1addRemove"));
            
            // Destroy.
            e.destroy();
        }
        
        [Test]
        public function testRecursiveAddition():void
        {
            // Recursively add components to an entity, then initialize it so onAdd is called.
            var e:IEntity = PBE.allocateEntity();
            e.addComponent(new RecursiveAddTestComponent(), "addRoot");
            e.initialize(null);
            
            // Validate they are all present by the time initialize finishes.
            Assert.assertNotNull("Initial add failed.", e.lookupComponentByName("addRoot"));
            for(var i:int=100; i>0; i--)
                Assert.assertNotNull("Recursive add failed at #" + i + ".", e.lookupComponentByName("c" + i + "add"));
            
            // Destroy.
            e.destroy();            
        }
    }
}
import com.pblabs.engine.entity.EntityComponent;

// Add new copies of ourselves from in our onAdd, up to a max count.
class RecursiveAddTestComponent extends EntityComponent
{
    public static var addCount:int = 100;
    
    protected override function onAdd() : void
    {
        if(addCount)
        {
            owner.addComponent(new RecursiveAddTestComponent(), "c" + addCount + "add");
            addCount--;
        }
    }
}

// Add new copies of ourselves from in our onAdd, up to a max count, and also
// remove ourselves. So we will generate lots of activity and end with a single
// component.
class RecursiveAddRemoveTestComponent extends EntityComponent
{
    public static var addCount:int = 100;
    
    protected override function onAdd() : void
    {
        if(addCount)
        {
            owner.addComponent(new RecursiveAddRemoveTestComponent(), "c" + addCount + "addRemove");
            owner.removeComponent(this);
            addCount--;
        }
    }
}