/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Engine.Entity
{
   /**
    * An implementation of the IEntityComponent interface, providing all the basic
    * functionality required of all components. Custom components should always
    * derive from this class rather than implementing IEntityComponent directly.
    * 
    * @includeExample SampleComponent.as
    * 
    * @see IEntity
    * @see ../../../../../Examples/CreatingComponents.html Creating Custom Components
    * @see ../../../../../Reference/ComponentSystem.html Component System Overview
    */
   public class EntityComponent implements IEntityComponent
   {
      /**
       * @inheritDoc
       */
      public function get Owner():IEntity
      {
         return _owner;
      }
      
      /**
       * @inheritDoc
       */
      public function get Name():String
      {
         return _name;
      }
      
      /**
       * @inheritDoc
       */
      public function get IsRegistered():Boolean
      {
         return _owner != null;
      }
      
      /**
       * @inheritDoc
       */
      public function Register(owner:IEntity, name:String):void
      {
         _name = name;
         _owner = owner;
         _OnAdd();
      }
      
      /**
       * @inheritDoc
       */
      public function Unregister():void
      {
         _OnRemove();
         _owner = null;
         _name = null;
      }
      
      /**
       * @inheritDoc
       */
      public function Reset():void
      {
         _OnReset();
      }
      
      /**
       * This is called when the component is added to an entity. Any initialization,
       * event registration, or object lookups should happen here. Component lookups
       * on the owner entity should NOT happen here. Use _OnReset instead.
       * 
       * @see #_OnReset()
       */
      protected function _OnAdd():void
      {
      }
      
      /**
       * This is called when the component is removed from an entity. It should reverse
       * anything that happened in _OnAdd or _OnReset (like removing event listeners or
       * nulling object references).
       */
      protected function _OnRemove():void
      {
      }
      
      /**
       * This is called anytime a component is added or removed from the owner entity.
       * Lookups of other components on the owner entity should happen here.
       * 
       * <p>This can potentially be called multiple times, so make sure previous lookups
       * are properly cleaned up each time.</p>
       */
      protected function _OnReset():void
      {
      }
      
      private var _owner:IEntity = null;
      private var _name:String = null;
   }
}