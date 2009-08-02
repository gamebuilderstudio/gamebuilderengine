package com.pblabs.engine.components
{
	import com.pblabs.engine.entity.EntityComponent;
   
   /**
    * Utility class to manage a group of entities marked with GroupManagerComponent.
    */
   public class GroupManagerComponent extends EntityComponent
   {
      private var _members:Array = new Array();
      
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