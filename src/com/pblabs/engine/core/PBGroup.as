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
    /**
     * A group which owns the objects contained it. When the PBGroup is
     * deleted, it deletes its owned objects. Assign a PBObject to a PBGroup
     * by setting object.owningGroup.
     */
    public class PBGroup extends PBObject
    {
        protected var items:Array = [];
        
        internal function addToGroup(item:IPBObject):Boolean
        {
            items.push(item);
            return true;
        }
        
        internal function removeFromGroup(item:IPBObject):Boolean
        {
            var idx:int = items.indexOf(item);
            if(idx == -1)
                return false;
            
            items.splice(idx, 1);
            return true
        }

        /**
         * Return the IPBObject at the specified index.
         */
        public function getItem(index:int):IPBObject
        {
            if(index < 0 || index >= items.length)
                return null;
            return items[index];
        }
        
        /**
         * How many PBObjects are in this group?
         */
        public function get length():int
        {
            return items.length;
        }
        
        /**
         * Destroy all the objects in this group, but do not delete the group.
         */
        public function clear():void
        {
            // Delete the items we own.
            while(items.length)
                (items.pop() as PBObject).destroy();            
        }
        
        public override function destroy() : void
        {
            // Delete everything.
            clear();
            
            // Pass control up.
            super.destroy();            
        }
    }
}