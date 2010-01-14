package com.pblabs.engine.core
{
    public class PBGroup extends PBObject
    {
        protected var items:Array = [];
        
        internal function addToGroup(item:PBObject):Boolean
        {
            items.push(item);
            return true;
        }
        
        internal function removeFromGroup(item:PBObject):Boolean
        {
            var idx:int = items.indexOf(item);
            if(idx == -1)
                return false;
            
            items.splice(idx, 1);
            return true
        }

        public function getItem(index:int):PBObject
        {
            if(index < 0 || index >= items.length)
                return null;
            return items[index];
        }
        
        public function get length():int
        {
            return items.length;
        }
        
        public override function destroy() : void
        {
            // Delete the items we own.
            while(items.length)
                (items.pop() as PBObject).destroy();
            
            // Pass control up.
            super.destroy();            
        }
    }
}