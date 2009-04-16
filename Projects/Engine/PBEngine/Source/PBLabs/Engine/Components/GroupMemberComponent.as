package PBLabs.Engine.Components
{
   import PBLabs.Engine.Entity.*;
   import PBLabs.Engine.Core.*;
   
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

      public function set GroupName(v:String):void
      {
         _OnRemove();

         _GroupName = v;

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