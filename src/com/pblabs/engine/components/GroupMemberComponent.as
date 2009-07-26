package com.pblabs.engine.components
{
   import com.pblabs.engine.entity.*;
   import com.pblabs.engine.core.*;
   
   /**
    * Helper component to group entities.
    */
   public class GroupMemberComponent extends EntityComponent
   {
      private var _groupName:String = null;
      private var _currentManager:GroupManagerComponent = null;
      
      public function get groupManager():GroupManagerComponent
      {
         return NameManager.instance.lookupComponentByType(groupName, GroupManagerComponent) as GroupManagerComponent;
      }

      public function set groupName(value:String):void
      {
         onRemove();

         _groupName = value;

         onAdd();
      }
      
      public function get groupName():String
      {
         return _groupName;
      }
      
      protected override function onAdd():void
      {
         var curM:GroupManagerComponent = groupManager;
         if(!_currentManager && curM)
         {
            _currentManager = curM;
            _currentManager.addMember(this);
         }
      }
      
      protected override function onReset():void
      {
         onRemove();
         onAdd();
      }
      
      protected override function onRemove():void
      {
         if(_currentManager)
         {
            _currentManager.removeMember(this);
            _currentManager = null;            
         }
      }
   }
}