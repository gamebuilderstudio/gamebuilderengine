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
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.serialization.ISerializable;
    
    [EditorData(editAs="Array", typeHint="String")]
    
    /**
     * An ObjectType is an abstraction of a bitmask that can be used to associate
     * objects with type names.
     * 
     * @see ObjectTypeManager
     */
    public class ObjectType implements ISerializable
    {
        /**
         * The bitmask that this type wraps. This should not be used directly. Instead,
         * use the various test methods on the ObjectTypeManager.
         * 
         * @see com.pblabs.engine.core.ObjectTypeManager.doesTypeMatch()
         * @see com.pblabs.engine.core.ObjectTypeManager.doesTypeOverlap()
         * @see com.pblabs.engine.core.ObjectTypeManager.doTypesMatch()
         * @see com.pblabs.engine.core.ObjectTypeManager.doTypesOverlap()
         */
        public function get bits():int
        {
            return _bits;
        }
        
        public function ObjectType(...arguments)
        {
            if(arguments.length == 1)
            {
                if(arguments[0] is Array)
                    typeNames = arguments[0];
                else
                    typeName = arguments[0];
            }
            else if(arguments.length > 1)
            {
                typeNames = arguments;
            }
        }
        
        /**
         * The name of the type associated with this object type. If multiple names have
         * been assigned, the one with the least significant bit is returned.
         */
        public function get typeName():String
        {
            for (var i:int = 0; i < PBE.objectTypeManager.typeCount; i++)
            {
                if (_bits & (1 << i))
                    return PBE.objectTypeManager.getTypeName(1 << i);
            }
            
            return "";
        }
        
        /**
         * @private
         */
        public function set typeName(value:String):void
        {
            _bits = PBE.objectTypeManager.getType(value);
        }
        
        /**
         * A list of all the type names associated with this object type.
         */
        public function get typeNames():Array
        {
            var array:Array = new Array();
            for (var i:int = 0; i < PBE.objectTypeManager.typeCount; i++)
            {
                if (_bits & (1 << i))
                    array.push(PBE.objectTypeManager.getTypeName(1 << i));
            }
            
            return array;
        }
        
        /**
         * @private
         */
        public function set typeNames(value:Array):void
        {
            _bits = 0;
            for each (var typeName:String in value)
            _bits |= PBE.objectTypeManager.getType(typeName);
        }
        
        
        /**
         * Add typeName to current ObjectType
         */
        public function add(typeName:String):void
        {
            _bits |= PBE.objectTypeManager.getType(typeName);	  	
        }      
        
        /**
         * Remove typeName from current ObjectType
         */
        public function remove(typeName:String):void
        { 		
            _bits &= (wildcard.bits - PBE.objectTypeManager.getType(typeName));	  		  	
        }
        
        /**
         * Perform a bitwise-and against another ObjectType and return true if they match.
         */
        public function and(other:ObjectType):Boolean
        {
            if((other.bits & bits) != 0)
                return true;
            else
                return false;
        }
        
        /**
         * @inheritDoc
         */
        public function serialize(xml:XML):void
        {
            var typeNames:Array = typeNames;
            if (typeNames.length == 1)
            {
                xml.appendChild(typeNames[0]);
                return;
            }
            
            for each (var typeName:String in typeNames)
                xml.appendChild(<type>{typeName}</type>);
        }
        
        /**
         * The xml description for this class can be either a single string, which will
         * then be assigned to the TypeName property, or a list of strings, each in their
         * own child tag (the name of which doesn't matter).
         * 
         * @inheritDoc
         */
        public function deserialize(xml:XML):*
        {
            if (xml.hasSimpleContent())
            {
                typeName = xml.toString();
                return this;
            }
            
            _bits = 0;
            for each (var childXML:XML in xml.*)
                _bits |= PBE.objectTypeManager.getType(childXML.toString());
            
            return this;
        }
        
        private var _bits:int = 0;
        
        private static var _wildcard:ObjectType;
        public static function get wildcard():ObjectType
        {
            if(!_wildcard)
                _wildcard = new ObjectType();
            
            _wildcard._bits = 0xFFFFFFFF;
            
            return _wildcard;         
        }
        
    }
}