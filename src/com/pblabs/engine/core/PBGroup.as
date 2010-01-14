package com.pblabs.engine.core
{
    public class PBGroup extends PBObject
    {
        protected var items:Array = [];
        
        internal function addToGroup(item:PBObject):void
        {
            items.push(item);
        }
        
        internal function removeFromGroup(item:PBObject):void
        {
            var idx:int = items.indexOf(item);
            if(idx == -1)
                throw new Error("item wasn't a member of this group!");
            items.splice(idx, 1);
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