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
    import com.pblabs.engine.debug.Logger;
    
    import flash.utils.Dictionary;
    
    /**
     * The ObjectTypeManager, together with the ObjectType class, is essentially an abstraction
     * of a bitmask to allow objects to be identified with friendly names, rather than complicated
     * numbers.
     * 
     * @see ObjectType
     */
    public class ObjectTypeManager
    {
        /**
         * The number of object types that have been registered.
         */
        public function get typeCount():uint
        {
            return _typeCount;
        }
        
        /**
         * Gets the number associated with a specified object type, registering it if
         * necessary.
         * 
         * @param typeName The name of the object type to retrieve.
         * 
         * @return The number associated with the specified type.
         */
        public function getType(typeName:String):uint
        {
            if (!_typeList.hasOwnProperty(typeName))
            {
                if (_typeCount == 64)
                {
                    Logger.warn(this, "GetObjectType", "Only 64 unique object types can be created.");
                    return 0;
                }
                
                _typeList[typeName] = _typeCount;
                _bitList[1 << _typeCount] = typeName;
                _typeCount++;
            }
            
            return 1 << _typeList[typeName];
        }
        
        /**
         * Gets the name of an object type based on the number it was assigned.
         * 
         * @param number The number of the type to find.
         * 
         * @return The name of the type with the specified number, or null if 
         * the number is not assigned to any type.
         */
        public function getTypeName(number:uint):String
        {
            return _bitList[number];
        }
        
        /**
         * Determines whether an object type is of the specified type.
         * 
         * @param type The type to check.
         * @param typeName The name of the type to check.
         * 
         * @return True if the specified type is of the specified type name. Keep in
         * mind, the type must match exactly, meaning, if it has multiple type names
         * associated with it, this will always return false.
         * 
         * @see #DoesTypeOverlap()
         */
        public function doesTypeMatch(type:ObjectType, typeName:String):Boolean
        {
            var t:* = _typeList[typeName];
            return (t != null) && type.bits == 1 << t;
        }
        
        /**
         * Determines whether an object type contains the specified type.
         * 
         * @param type The type to check.
         * @param typeName The name of the type to check.
         * 
         * @return True if the specified type is of the specified type name. Keep in
         * mind, the type must only contain the type name, meaning, if it has multiple
         * type names associated with it, only one of them has to match.
         * 
         * @see #DoesTypeMatch()
         */
        public function doesTypeOverlap(type:ObjectType, typeName:String):Boolean
        {
            var t:* = _typeList[typeName];
            return (t != null) && (type.bits & (1 << t)) != 0;
        }
        
        /**
         * Determines whether two object types are of the same type.
         * 
         * @param type1 The type to check.
         * @param type2 The type to check against.
         * 
         * @return True if type1 and type2 contain the exact same types.
         */
        public function doTypesMatch(type1:ObjectType, type2:ObjectType):Boolean
        {
            return type1.bits == type2.bits;
        }
        
        /**
         * Determines whether two object types have overlapping types.
         * 
         * @param type1 The type to check.
         * @param type2 The type to check against.
         * 
         * @return True if type1 has any of the type contained in type2.
         */
        public function doTypesOverlap(type1:ObjectType, type2:ObjectType):Boolean
        {
            if (!type1 || !type2)
                return false;
            
            return (type1.bits & type2.bits) != 0;
        }
        
        /**
         * Forcibly register a specific flag. Throws an error if you overwrite an
         * existing flag.
         */
        public function registerFlag(bitIndex:int, name:String):void
        {
            // Sanity.
            if(getTypeName(bitIndex) != null) 
                throw new Error("Bit already in use!");
            if(_typeList[name])
                throw new Error("Name already assigned to another bit!");
            
            // Update typeCount so subsequent updates still work. This may
            // cause wasted bits.
            if(bitIndex >= _typeCount)
                _typeCount = bitIndex + 1;
            
            // And stuff into our arrays.
            _typeList[name] = bitIndex;
            _bitList[bitIndex] = name;
        }
        
        private var _typeCount:uint = 0;
        private var _typeList:Dictionary = new Dictionary();
        private var _bitList:Array = new Array();
    }
}