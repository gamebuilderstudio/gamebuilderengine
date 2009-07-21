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
    * Game objects in PBE are referred to as entities. This interface defines the
    * behavior for an entity. A full featured implementation of this interface is
    * included, but is hidden so as to force using IEntity when storing references
    * to entities. To create a new entity, use AllocateEntity.
    * 
    * <p>An entity by itself is a very light weight object. All it needs to store is
    * its name and a list of components. Custom functionality is added by creating
    * components and attaching them to entities.</p>
    * 
    * <p>An event with type "EntityDestroyed" will be fired when the entity is
    * destroyed via the Destroy() method. This event is fired before any cleanup
    * is done.</p>
    *  
    * @see IEntityComponent
    * @see PBLabs.Engine.Entity.AllocateEntity()
    */
   public interface IEntity extends IPropertyBag
   {
      /**
       * The name of the entity. This is set by passing a name to the Initialize
       * method after the entity is first created.
       * 
       * @see #Initialize()
       */
      function get Name():String;
      
      /**
       * Initializes the entity, optionally assigning it a name. This should be
       * called immediately after the entity is created.
       * 
       * @param name The name to assign to the entity. If this is null or an empty
       * string, the entity will not register itself with the name manager.
       * 
       * @param alias An alternate name under which this entity can be looked up.
       * Useful when you need to distinguish between multiple things but refer
       * to the active one by a consistent name.
       *
       * @see PBLabs.Engine.Core.NameManager
       */
      function Initialize(name:String, alias:String = null):void;

      /**
       * Destroys the entity by removing all components and unregistering it from
       * the name manager.
       * 
       * <p>Currently this will not invalidate external references to the entity
       * so the entity will only be cleaned up by the garbage collector if those
       * are set to null manually.</p>
       */
      function Destroy():void;
      
      /**
       * Adds a component to the entity.
       * 
       * <p>When a component is added, it will have its Register method called
       * (or _OnAdd if it is derived from EntityComponent). Also, Reset will be
       * called on all components currently attached to the entity (or _OnReset
       * if it is derived from EntityComponent).</p>
       * 
       * @param component The component to add.
       * @param componentName The name to set for the component. This is the value
       * to use in LookupComponentByName to get a reference to the component. The
       * name must be unique across all components on this entity.
       */
      function AddComponent(component:IEntityComponent, componentName:String):void;
      
      /**
       * Removes a component from the entity.
       * 
       * <p>When a component is removed, it will have its Unregister method called
       * (or _OnRemove if it is derived from EntityComponent). Also, Reset will be
       * called on all components currently attached to the entity (or _OnReset
       * if it is derived from EntityComponent).</p>
       * 
       * @param component The component to remove.
       */
      function RemoveComponent(component:IEntityComponent):void;
      
      /**
       * Creates an XML description of this entity, including all currently attached
       * components.
       * 
       * <p>This is not implemented yet.</p>
       * 
       * @param xml The xml object describing the entity. The parent tag should be
       * included in this variable when the function is called, so only child tags
       * need to be created.
       * 
       * @see ../../../../../Reference/XMLFormat.html The XML Format
       */
      function Serialize(xml:XML):void;
      
      /**
       * Sets up this entity from an xml description.
       * 
       * @param xml The xml object describing the entity.
       * @param registerComponents Set this to false to add components to the entity
       * without registering them. This is used by the level manager to facilitate
       * creating entities from templates. 
       * 
       * @see ../../../../../Reference/XMLFormat.html The XML Format
       * @see ../../../../../Reference/Levels.html Levels
       */
      function Deserialize(xml:XML, registerComponents:Boolean = true):void;
      
      /**
       * Gets a component of a specific type from this entity. If more than one
       * component of a specific type exists, there is no guarantee which one
       * will be returned. To retrieve all components of a specified type, use
       * LookupComponentsByType.
       * 
       * @param componentType The type of the component to retrieve.
       * 
       * @return The component, or null if none of the specified type were found.
       * 
       * @see #LookupComponentsByType()
       */
      function LookupComponentByType(componentType:Class):IEntityComponent;
      
      /**
       * Gets a list of all the components of a specific type that are on this
       * entity.
       * 
       * @param componentType The type of components to retrieve.
       * 
       * @return An array containing all the components of the specified type on
       * this entity.
       */
      function LookupComponentsByType(componentType:Class):Array;
      
      /**
       * Gets a component that was registered with a specific name on this entity.
       * 
       * @param componentName The name of the component to retrieve. This corresponds
       * to the second parameter passed to AddComponent.
       * 
       * @return The component with the specified name.
       * 
       * @see #AddComponent()
       */
      function LookupComponentByName(componentName:String):IEntityComponent;
   }
}