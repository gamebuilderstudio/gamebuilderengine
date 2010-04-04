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
     * Interface for a named object that can exist in a group or set.
     * 
     * @see PBSet, PBGroup, IEntity
     */
    public interface IPBObject
    {
        /**
         * The name of the PBObject. This is set by passing a name to the initialize
         * method after the PBObject is first created.
         * 
         * @see #initialize()
         */
        function get name():String;
        
        /**
         * Since the PBE level format references template definitions by name, and
         * that same name is used to name the entities created by the format, it
         * is useful to be able to look things up by a common name. So you might
         * have Level1Background, Level2Background, Level3Background etc. but give
         * them all the alias LevelBackground so you can look up the current level's
         * background easily.
         * 
         * <p>This is set by the second parameter to #initialize()</p>
         */
        function get alias():String;
        
        /**
         * The PBGroup which owns this PBObject. If the owning group is destroy()ed,
         * the PBObject is destroy()ed as well. This is useful for managing object
         * lifespans - for instance, all the PBObjects in a level might belong
         * to one common group for easy cleanup.
         */
        function set owningGroup(value:PBGroup):void;
        function get owningGroup():PBGroup;
        
        /**
         * initializes the PBObject, optionally assigning it a name. This should be
         * called immediately after the PBObject is created.
         * 
         * @param name The name to assign to the PBObject. If this is null or an empty
         * string, the PBObject will not register itself with the name manager.
         * 
         * @param alias An alternate name under which this PBObject can be looked up.
         * Useful when you need to distinguish between multiple things but refer
         * to the active one by a consistent name.
         *
         * @see com.pblabs.engine.core.NameManager
         */
        function initialize(name:String = null, alias:String = null):void;
        
        /**
         * Destroys the PBObject by removing all components and unregistering it from
         * the name manager.
         * 
         * <p>PBObjects are automatically removed from any groups/sets that they
         * are members of when they are destroy()'ed.</P>
         * 
         * <p>Currently this will not invalidate any other references to the PBObject
         * so the PBObject will only be cleaned up by the garbage collector if those
         * are set to null manually.</p>
         */
        function destroy():void;
    }
}