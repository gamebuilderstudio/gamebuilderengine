package com.pblabs.engine.components
{
   import com.pblabs.engine.entity.*;
   import com.pblabs.engine.core.*;
   
   /**
    * Helper component to group entities.
    */
   public class GroupMemberComponent extends EntityComponent
   {
      private var _GroupName:String = null;
      private var _CurrentManager:GroupManagerComponent = null;
      
      public function get GroupManager():GroupManagerComponent
      {
         return NameManager.Instance.LookupComponentByType(GroupName, GroupManagerComponent) as GroupManagerComponent;
      }

      public function set GroupName(value:String):void
      {
         _OnRemove();

         _GroupName = value;

         _OnAdd();
      }
      
      public function get GroupName():String
      {
         return _GroupName;
      }
      
      protected override function _OnAdd():void
      {
         var curM:GroupManagerComponent = GroupManager;
         if(!_CurrentManager && curM)
         {
            _CurrentManager = curM;
            _CurrentManager.AddMember(this);
         }
      }
      
      protected override function _OnReset():void
      {
         _OnRemove();
         _OnAdd();
      }
      
      protected override function _OnRemove():void
      {
         if(_CurrentManager)
         {
            _CurrentManager.RemoveMember(this);
            _CurrentManager = null;            
         }
      }
   }
}