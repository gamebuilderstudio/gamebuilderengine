package com.pblabs.engine.components
{
   import com.pblabs.engine.entity.*;
   
   /**
    * Utility class to manage a group of entities marked with GroupManagerComponent.
    */
   public class GroupManagerComponent extends EntityComponent
   {
      private var _Members:Array = new Array();
      
      public function AddMember(member:GroupMemberComponent):void
      {
         _Members.push(member);
      }   
      
      public function RemoveMember(member:GroupMemberComponent):void
      {
         var idx:int = _Members.indexOf(member);
         if(idx == -1)
            throw new Error("Removing a member which does not exist in this group.");
         _Members.splice(idx, 1);
      }
      
      public function get EntityList():Array
      {
         var a:Array = new Array();
         
         for each(var m:GroupMemberComponent in _Members)
            a.push(m.Owner);
            
         return a;
      }
         
   }
}