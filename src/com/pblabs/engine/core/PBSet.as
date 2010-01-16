package com.pblabs.engine.core
{
    import flash.events.Event;

    /**
     * Set of PBObjects. A PBObject may be in many sets; sets do not destroy
     * their contained objects when they are destroyed. Sets automatically
     * remove destroy()'ed objects. 
     */
    public class PBSet extends PBObject
    {
        protected var items:Array = [];

        public function getItem(index:int):PBObject
        {
            if(items == null)
                return null;
            
            if(index < 0 || index >= items.length)
                return null;
            return items[index];
        }
        
        public function get length():int
        {
            return items ? items.length : 0;
        }
        
        public function contains(item:PBObject):Boolean
        {
            if(items == null)
                throw new Error("Accessing destroy()'ed set.");

            return (items.indexOf(item) != -1);
        }
        
        public function add(item:PBObject):Boolean
        {
            if(items == null)
                throw new Error("Accessing destroy()'ed set.");

            // Was the item present?
            if(contains(item))
                return false;
            
            // No, add it.
            item.noteInSet(this);
            items.push(item);
            return true;
        }
        
        public function remove(item:PBObject):Boolean
        {
            if(items == null)
                throw new Error("Accessing destroy()'ed set.");

            // Is item present?
            var idx:int = items.indexOf(item);
            if(idx == -1)
                return false;
            
            // Yes, remove it.
            item.noteOutOfSet(this);
            items.splice(idx, 1);
            return true;
        }
        
        public override function destroy() : void
        {
            if(items == null)
                throw new Error("Accessing destroy()'ed set.");

            // Clear out items.
            while(items.length)
                remove(items.pop() as PBObject);
            items = null;
            
            // Pass control up.
            super.destroy();
        }
    }
}