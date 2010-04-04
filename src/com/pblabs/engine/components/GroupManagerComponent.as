/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.components
{
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.core.NameManager;
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.engine.entity.EntityComponent;
    import com.pblabs.engine.entity.IEntity;
    import com.pblabs.engine.entity.allocateEntity;
   
    /**
     * Utility class to manage a group of entities marked with GroupManagerComponent.
     */
    public class GroupManagerComponent extends EntityComponent
    {
        private var _members:Array = new Array();
       
        public static var autoCreateNamedGroups:Boolean = true;
      
        public static function getGroupByName(name:String):GroupManagerComponent
        {
            var groupName:String = name;
         
            var gm:GroupManagerComponent = PBE.lookupComponentByType(groupName, GroupManagerComponent) as GroupManagerComponent
         
            if (gm == null) 
            {
                if (!autoCreateNamedGroups) 
                {
                    Logger.warn(GroupManagerComponent, "GetGroupByName", "Tried to reference non-existent group '" + groupName + "'");
                }
                else 
                {
                    var ent:IEntity = allocateEntity();
                    ent.initialize(groupName);
              
                    gm = new GroupManagerComponent();
             
                    ent.addComponent(gm, name);
                }
            }

            return gm;
        }
 
        public function addMember(member:GroupMemberComponent):void
        {
            _members.push(member);
        }   
      
        public function removeMember(member:GroupMemberComponent):void
        {
            var idx:int = _members.indexOf(member);
            if(idx == -1)
                throw new Error("Removing a member which does not exist in this group.");
            _members.splice(idx, 1);
        }
      
        public function get entityList():Array
        {
            var a:Array = new Array();
         
            for each(var m:GroupMemberComponent in _members)
                a.push(m.owner);
            
            return a;
        }
      
    }
}