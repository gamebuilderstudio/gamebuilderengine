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
   import PBLabs.Engine.Serialization.ISerializable;
   
   /**
    * A property reference stores the information necessary to lookup a property
    * on an entity.
    * 
    * <p>These are used to facilitate retrieving information from entities without
    * requiring a specific interface to be implemented. For example, a component that
    * handles display information would need to retrieve spatial information from a
    * spatial component. The spatial component can store its information however it
    * sees fit. The display component would have a PropertyReference member that would
    * be initialized to the path of the desired property on the spatial component.</p>
    * 
    * @see IEntity#DoesPropertyExist()
    * @see IEntity#GetProperty()
    * @see IEntity#SetProperty()
    * @see ../../../../../Reference/PropertySystem.html Property System Overview
    */
   public class PropertyReference implements ISerializable
   {
      /**
       * The path to the property that this references.
       */
      public function get Property():String
      {
         return _property;
      }
      
      /**
       * @private
       */
      public function set Property(value:String):void
      {
         _property = value;
      }
      
      public function PropertyReference(property:String = null)
      {
         _property = property;
      }
      
      /**
       * @inheritDoc
       */
      public function Serialize(xml:XML):void
      {
         xml.appendChild(new XML(_property));
      }
      
      /**
       * @inheritDoc
       */
      public function Deserialize(xml:XML):*
      {
         _property = xml.toString();
         return this;
      }
      
      private var _property:String = null;
      public var CachedLookup:Array;
   }
}