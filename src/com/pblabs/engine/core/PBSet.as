package com.pblabs.engine.core
{
    public class PBSet extends PBObject
    {
        protected var items:Array = [];

        public function getItems():Array
        {
            if(items == null)
                throw new Error("Accessing destroy()'ed set.");

            return items;
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
            items.splice(idx, 1);
            return true;
        }
        
        public override function destroy() : void
        {
            if(items == null)
                throw new Error("Accessing destroy()'ed set.");

            items.length = 0;
            items = null;
            
            super.destroy();
        }
    }
}