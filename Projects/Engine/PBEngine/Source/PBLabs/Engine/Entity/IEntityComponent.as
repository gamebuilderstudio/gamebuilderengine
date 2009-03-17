package PBLabs.Engine.Entity
{
   /**
    * A component in PBE is used to define specific pieces of functionality for
    * game entities. Several components can be added to a single entity to give
    * the entity complex behavior while keeping the different functionalities separate
    * from each other.
    * 
    * <p>A full featured implementation of this interface is included (EntityComponent).
    * It should be adequate for almost every situation, and therefore, custom components
    * should derive from it rather than implementing this interface directly.</p>
    * 
    * <p>There are several reasons why PBE is set up this way:
    * <bl>
    *    <li>Entities have only the data they need and nothing more.</li>
    *    <li>Components can be reused on several different types of entities.</li>
    *    <li>Programmers can focus on specific pieces of functionality when writing code.</li>
    * </bl>
    * </p>
    * 
    * @see IEntity
    * @see EntityComponent
    * @see ../../../../../Examples/CreatingComponents.html Creating Custom Components
    * @see ../../../../../Reference/ComponentSystem.html Component System Overview
    */
   public interface IEntityComponent
   {
      /**
       * A reference to the entity that this component currently belongs to. If
       * the component has not been added to an entity, this will be null.
       * 
       * This value should be equivelent to the first parameter passed to the Register
       * method.
       * 
       * @see #Register() 
       */
      function get Owner():IEntity;
      
      /**
       * The name given to the component when it is added to an entity.
       * 
       * This value should be equivelent to the second parameter passed to the Register
       * method.
       * 
       * @see #Register() 
       */
      function get Name():String;
      
      /**
       * Whether or not the component is currently registered with an entity.
       */
      function get IsRegistered():Boolean;
      
      /**
       * Registers the component with an entity. This should only ever be called by
       * an entity class from the AddComponent method.
       * 
       * @param owner The entity to register the component with.
       * @param name The name to assign to the component.
       */
      function Register(owner:IEntity, name:String):void;
      
      /**
       * Unregisters the component from an entity. This should only ever be called by
       * an entity class from the RemoveComponent method.
       */
      function Unregister():void;
      
      /**
       * This is called by an entity on all of its components any time a component
       * is added or removed. In this method, any references to properties on the
       * owner entity should be purged and re-looked up.
       */
      function Reset():void;
   }
}