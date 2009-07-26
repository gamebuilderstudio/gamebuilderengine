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
      
      public function get groupManager():GroupManagerComponent
      {
         return NameManager.instance.lookupComponentByType(groupName, GroupManagerComponent) as GroupManagerComponent;
      }

      public function set groupName(value:String):void
      {
         onRemove();

         _GroupName = value;

         onAdd();
      }
      
      public function get groupName():String
      {
         return _GroupName;
      }
      
      protected override function onAdd():void
      {
         var curM:GroupManagerComponent = groupManager;
         if(!_CurrentManager && curM)
         {
            _CurrentManager = curM;
            _CurrentManager.addMember(this);
         }
      }
      
      protected override function onReset():void
      {
         onRemove();
         onAdd();
      }
      
      protected override function onRemove():void
      {
         if(_CurrentManager)
         {
            _CurrentManager.removeMember(this);
            _CurrentManager = null;            
         }
      }
   }
}