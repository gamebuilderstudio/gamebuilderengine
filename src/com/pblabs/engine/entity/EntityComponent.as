/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.entity
{
   [EditorData(ignore="true")]
   
   /**
    * An implementation of the IEntityComponent interface, providing all the basic
    * functionality required of all components. Custom components should always
    * derive from this class rather than implementing IEntityComponent directly.
    * 
    * @see IEntity
    */
   public class EntityComponent implements IEntityComponent
   {
      /**
       * @inheritDoc
       */
      [EditorData(ignore="true")]
      public function get owner():IEntity
      {
         return _owner;
      }
      
      public function set owner(value:IEntity):void
      {
          _owner = value;
      }
      
      /**
       * @inheritDoc
       */
      [EditorData(ignore="true")]
      public function get name():String
      {
         return _name;
      }
      
      /**
       * @inheritDoc
       */
      [EditorData(ignore="true")]
      public function get isRegistered():Boolean
      {
         return _isRegistered;
      }
      
      /**
       * @inheritDoc
       */
      public function register(owner:IEntity, name:String):void
      {
         if(isRegistered)
            throw new Error("Trying to register an already-registered component!");
            
         _name = name;
         _owner = owner;
         onAdd();
         _isRegistered = true;
      }
      
      /**
       * @inheritDoc
       */
      public function unregister():void
      {
         if(!isRegistered)
            throw new Error("Trying to unregister an unregistered component!");

         _isRegistered = false;
         onRemove();
         _owner = null;
         _name = null;
      }
      
      /**
       * @inheritDoc
       */
      public function reset():void
      {
         onReset();
      }
      
      /**
       * This is called when the component is added to an entity. Any initialization,
       * event registration, or object lookups should happen here. Component lookups
       * on the owner entity should NOT happen here. Use onReset instead.
       * 
       * @see #onReset()
       */
      protected function onAdd():void
      {
      }
      
      /**
       * This is called when the component is removed from an entity. It should reverse
       * anything that happened in onAdd or onReset (like removing event listeners or
       * nulling object references).
       */
      protected function onRemove():void
      {
      }
      
      /**
       * This is called anytime a component is added or removed from the owner entity.
       * Lookups of other components on the owner entity should happen here.
       * 
       * <p>This can potentially be called multiple times, so make sure previous lookups
       * are properly cleaned up each time.</p>
       */
      protected function onReset():void
      {
      }
      
      private var _isRegistered:Boolean = false;
      private var _owner:IEntity = null;
      private var _name:String = null;
   }
}