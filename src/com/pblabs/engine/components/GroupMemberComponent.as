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
	import com.pblabs.engine.core.NameManager;
	import com.pblabs.engine.entity.EntityComponent;

   /**
    * Helper component to group entities.
    */
   public class GroupMemberComponent extends EntityComponent
   {
      private var _groupName:String = null;
      private var _currentManager:GroupManagerComponent = null;
      
      public function get groupManager():GroupManagerComponent
      {
      	 return GroupManagerComponent.getGroupByName(_groupName);
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
      
      override protected function onAdd():void
      {
         var curM:GroupManagerComponent = groupManager;
         if(!_currentManager && curM)
         {
            _currentManager = curM;
            _currentManager.addMember(this);
         }
      }
      
      override protected function onReset():void
      {
         onRemove();
         onAdd();
      }
      
      override protected function onRemove():void
      {
         if(_currentManager)
         {
            _currentManager.removeMember(this);
            _currentManager = null;            
         }
      }
   }
}