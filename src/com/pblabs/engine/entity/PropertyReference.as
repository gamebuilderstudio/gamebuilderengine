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
    import com.pblabs.engine.serialization.ISerializable;
    import com.pblabs.engine.debug.Logger;
    
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
     * <p>Property References follow one of three formats, component lookup, global
     * entity lookup, or xml lookup.  For component lookup the property reference
     * should start with an &#64;, for global entity lookup the property reference should
     * start with a #, and for xml lookup the property reference should start with a !.
     * Following this starting symbol comes the name of the component, entity or XML 
     * Template respectively.</p>
     * 
     * @example The following code gets the x property of the position property of the 
     * spatial component on the queried Entity: <listing version="3.0">
     * &#64;spatial.position.x
     * </listing>
     * 
     * @example Property references can also access arrays and dictionaries.  The following
     * property reference is equivalent to ai.targets[0].x: <listing version="3.0">
     * &#64;ai.targets.0.x
     * </listing>
     * 
     * @example Global entities can be accessed with the # symbol.  The following code accesses
     * the Level entity's timer component and retrieves the timeLeft property: <listing version="3.0">
     * #Level.timer.timeLeft
     * </listing>
     * 
     * @example XML Template properties can be accessed using the ! symbol.  The following code accesses
		 * the XML Template name Enemy and retrieves the health property off of the life component: <listing version="3.0">
     * !Enemy.life.health
     * </listing>
		 *
     * @see IPropertyBag#doesPropertyExist()
     * @see IPropertyBag#getProperty()
     * @see IPropertyBag#setProperty()
     */
    public class PropertyReference implements ISerializable
    {
        /**
         * The path to the property that this references.
         */
        public function get property():String
        {
            return _property;
        }
        
        /**
         * @private
         */
        public function set property(value:String):void
        {
            if (_property != value) {
                cachedLookup = null;
            }
            _property = value;
        }
        
        public function PropertyReference(property:String = null)
        {
            _property = property;
        }
        
        /**
         * @inheritDoc
         */
        public function serialize(xml:XML):void
        {
            xml.appendChild(new XML(_property));
        }
        
        /**
         * @inheritDoc
         */
        public function deserialize(xml:XML):*
        {
            if(_property)
                Logger.warn(this, "deserialize", "Overwriting property; was '" + _property + "', new value is '" + xml.toString() + "'");
            _property = xml.toString();
            return this;
        }
        
        public function toString():String
        {
            return _property;
        }
        
        private var _property:String = null;
        public var cachedLookup:Array;
    }
}
