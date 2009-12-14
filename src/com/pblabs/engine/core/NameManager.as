/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.core
{
   import com.pblabs.engine.entity.IEntity;
   import com.pblabs.engine.entity.IEntityComponent;
   import com.pblabs.engine.debug.Logger;
   
   import flash.utils.Dictionary;
   
   /**
    * The name manager stores references to entites that have been given
    * names. These entities can then be looked up by that name.
    */
   public class NameManager
   {
      /**
       * The singleton NameManager instance.
       */
      public static function get instance():NameManager
      {
         if (!_instance)
            _instance = new NameManager();
         
         return _instance;
      }
      
      private static var _instance:NameManager = null;
      
      /**
       * The list of registered entities.
       */
      public function get entityList():Dictionary
      {
         return _entities;
      }
      
      /**
       * Registers an entity under a specific name. If the name is in use, lookups will
       * return the last entity added under the name.
       * 
       * @param entity The entity to add.
       * @param name The name to register the entity under.
       */
      public function addEntity(entity:IEntity, name:String):void
      {
         if (_entities[name])
            Logger.warn(this, "AddEntity", "An entity with the name " + name + " already exists. Future lookups by this name will return this new entity. Did you mean to make this entity a template?");
         
         if(TemplateManager.VERBOSE_LOGGING)
            Logger.print(this, "Registering entity '" + name + "'");
            
         _entities[name] = entity;
      }
      
      /**
       * Removes an entity from the manager.
       * 
       * @param entity The entity to remove.
       */
      public function removeEntity(entity:IEntity):void
      {
      	if (entity.alias && _entities[entity.name] == _entities[entity.alias])
      	{
           _entities[entity.alias] = null;
           delete _entities[entity.alias];                  
      	}      	      	
         _entities[entity.name] = null;
         delete _entities[entity.name];                  
      }
      
      /**
       * Looks up an entity with the specified name.
       * 
       * @param name The name of the entity to lookup.
       * 
       * @return The entity with the specified name, or null if it wasn't found.
       */
      public function lookup(name:String):IEntity
      {
         return _entities[name];
      }
      
      /**
       * Turns a potentially used name and returns a related unused name. The
       * given name will have a number appended, with the number continually
       * incremented until an unused name is found.
       * 
       * @param name The name to validate.
       * 
       * @return The validated name. This is guaranteed to not be in use.
       */
      public function validateName(name:String):String
      {
         if (!_entities[name])
            return name;
         
         var index:int = 1;
         var testName:String = name + index;
         while (_entities[testName])
            testName = name + index++;
         
         return testName;
      }
      
      /**
       * Looks up a component on an entity that has been registered. The same
       * conditions apply as with the lookupComponentByType method on IEntity.
       * 
       * @param The name of the entity on which the component exists.
       * @param componentType The type of the component to lookup.
       * 
       * @see com.pblabs.engine.entity.IEntity#lookupComponentByType()
       */
      public function lookupComponentByType(name:String, componentType:Class):IEntityComponent
      {
         var entity:IEntity = lookup(name);
         if (!entity)
            return null;
         
         return entity.lookupComponentByType(componentType);
      }
      
      /**
       * Looks up components on an entity that has been registered. The same
       * conditions apply as with the lookupComponentsByType method on IEntity.
       * 
       * @param The name of the entity on which the component exists.
       * @param componentType The type of the components to lookup.
       * 
       * @see com.pblabs.engine.entity.IEntity#lookupComponentByType()
       */
      public function lookupComponentsByType(name:String, componentType:Class):Array
      {
         var entity:IEntity = lookup(name);
         if (!entity)
            return null;
         
         return entity.lookupComponentsByType(componentType);
      }      
      
      /**
       * Looks up a component on an entity that has been registered. The same
       * conditions apply as with the lookupComponentByName method on IEntity.
       * 
       * @param The name of the entity on which the component exists.
       * @param componentName The name of the component to lookup.
       * 
       * @see com.pblabs.engine.entity.IEntity#lookupComponentByName()
       */
      public function lookupComponentByName(name:String, componentName:String):IEntityComponent
      {
         var entity:IEntity = lookup(name);
         if (!entity)
            return null;
         
         return entity.lookupComponentByName(componentName);
      }
      
      private var _entities:Dictionary = new Dictionary();
   }
}