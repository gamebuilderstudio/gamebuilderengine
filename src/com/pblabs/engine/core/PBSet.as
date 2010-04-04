/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.core
{
    import com.pblabs.engine.debug.Logger;
    
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
            // Can't add ourselves to ourselves.
            if(item == this)
                return false;
            
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
            // Can't remove ourselves from ourselves.
            if(item == this)
                return false;
            
            if(items == null)
            {
                //throw new Error("Accessing destroy()'ed set.");
                Logger.warn(this, "remove", "Removed item from dead PBSet.");
                item.noteOutOfSet(this);
                return true;
            }

            // Is item present?
            var idx:int = items.indexOf(item);
            if(idx == -1)
                return false;
            
            // Yes, remove it.
            item.noteOutOfSet(this);
            items.splice(idx, 1);
            return true;
        }
        
        /**
         * Destroy all the objects in this set, but do not delete the set.
         */
        public function clear():void
        {
            // Delete the items we own.
            while(items.length)
                (items.pop() as PBObject).destroy();            
        }

        public override function destroy() : void
        {
            if(items == null)
                throw new Error("Accessing destroy()'ed set.");

            // Pass control up.
            super.destroy();

            // Clear out items.
            while(items.length)
                remove(items.pop() as PBObject);
            items = null;
        }
    }
}