/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.serialization
{
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.engine.entity.IEntity;
     import com.pblabs.engine.entity.IEntityComponent;
     import flash.geom.Point;
     import flash.utils.getQualifiedClassName;
    
    import flash.utils.Dictionary;
    
    /**
     * Singleton class for serializing and deserializing objects. This class 
     * implements a default serialization behavior based on the format described
     * in the XMLFormat reference. This default behavior can be replaced on a class
     * by class basis by implementing the ISerializable interface.
     * 
     * @see ISerializable
     */
    public class Serializer
    {
        /**
         * Gets the singleton instance of the Serializer class.
         */
        public static function get instance():Serializer
        {
            if (!_instance)
                _instance = new Serializer();
            
            return _instance;
        }
        
        private static var _instance:Serializer = null;
        
        public function Serializer()
        {
            // initialize our default Serializers. Note "special" cases get a double
            // colon so there can be no overlap w/ any real type.
            _deserializers["::DefaultSimple"] = deserializeSimple;
            _deserializers["::DefaultComplex"] = dserializeComplex;
            _deserializers["Boolean"] = deserializeBoolean;
            _deserializers["Array"] = deserializeDictionary;
            _deserializers["flash.utils::Dictionary"] = deserializeDictionary;
            _deserializers["Class"] = deserializeClass;
            
            _serializers["::DefaultSimple"] = serializeSimple;
            _serializers["::DefaultComplex"] = serializeComplex;
            _serializers["Boolean"] = serializeBoolean;
            _serializers["Array"] = serializeDictionary;
            _serializers["flash.utils::Dictionary"] = serializeDictionary;
            
            // Do a quick sanity check to make sure we are getting metadata.
            var tmd:TestForMetadata = new TestForMetadata();
            if(TypeUtility.getTypeHint(tmd, "someArray") != "Number")
            {
                // Don't error, as it makes it very hard for CS4 people to develop.
                Logger.print(this, "Metadata is not included in this build of the engine, so serialization will not work!\n" + 
                    "Add --keep-as3-metadata+=TypeHint,EditorData,Embed to your compiler arguments to get around this.");
            }
        }
        
        /**
         * Serializes an object to XML. This is currently not implemented.
         * 
         * @param object The object to serialize. If this object implements ISerializable,
         * its serialize method will be called to do the serialization, otherwise the default
         * behavior will be used.
         * 
         * @return The xml describing the specified object.
         * 
         * @see ISerializable
         */
        public function serialize(object:*, xml:XML):void
        {
            if (object is ISerializable)
            {
                (object as ISerializable).serialize(xml);
            }
            else if (object is IEntity)
            {
                _currentEntity = object as IEntity;
                _currentEntity.serialize(xml);
            }
            else
            {
                // Normal case - determine type and call the right Serializer.
                var typeName:String = TypeUtility.getObjectClassName(object);
                if (!_serializers[typeName])
                    typeName = isSimpleType(object) ? "::DefaultSimple" : "::DefaultComplex";
                
                _serializers[typeName](object, xml);
            }
        }
        
        /**
         * Deserializes an object from an xml description.
         * 
         * @param object The object on which the xml description will be applied.
         * @param xml The xml to deserialize from.
         * @param typeHint For an array, dictionary, or dynamic class, a type hint can
         *                be specified as to what its children should be. Optional.
         * 
         * @return A reference to the deserialized object. This is always the same as
         * the object parameter, with the exception of types that are passed by value.
         * Code that calls this method should always use the return value rather than
         * the passed in value for this reason.
         */
        public function deserialize(object:*, xml:XML, typeHint:String=null):*
        {
            // Dispatch our special cases - entities and ISerializables.
            if (object is ISerializable)
            {
                return ISerializable(object).deserialize(xml);
            }
            else if (object is IEntity)
            {
                _currentEntity = object as IEntity;
                _currentEntity.deserialize(xml, true);
                resolveReferences();
                return object as IEntity;
            }
            
            // Normal case - determine type and call the right Serializer.
            var typeName:String = TypeUtility.getObjectClassName(object);
            if (!_deserializers[typeName])
                typeName = xml.hasSimpleContent() ? "::DefaultSimple" : "::DefaultComplex";
            
            return _deserializers[typeName](object, xml, typeHint);
        }
        
        /**
         * Set the entity relative to which current serialization work is happening. Mostly for internal use.
         */
        public function setCurrentEntity(e:IEntity):void
        {
            _currentEntity = e;
        }
        
        /**
         * Clear the entity relative to which current serialization work is happening. Mostly for internal use.
         */
        public function clearCurrentEntity():void
        {
            _currentEntity = null;
        }
        
        /**
         * Not all references are resolved immediately. In order to minimize spam,
         * we only report "dangling references" at certain times. This method 
         * triggers such a report.
         */
        public function reportMissingReferences():void
        {
            for (var i:int = 0; i < _deferredReferences.length; i++)
            {
                var reference:ReferenceNote = _deferredReferences[i];
                reference.reportMissing();
            }
        }
        
        private function isSimple(xml:XML, typeName:String):Boolean
        {
            // Complex content is assumed if there are child nodes in the xml, or the xml text is
            // an empty string, unless the type is a string. This is because any simple type that
            // is not a string has to have a value. Otherwise, it must be a class that doesn't have
            // its children specified.
            if (typeName == "String")
                return true;
            
            if (xml.hasComplexContent())
                return false;
            
            if (xml.toString() == "")
                return false;
            
            return true;
        }
        
        private function isSimpleType(object:*):Boolean
        {
            var typeName:String = TypeUtility.getObjectClassName(object);
            if (typeName == "String" || typeName == "int" || typeName == "Number" || typeName == "uint" || typeName == "Boolean")
                return true;
            
            return false;
        }
        
        private function deserializeSimple(object:*, xml:XML, typeHint:String):*
        {
            // If the tag is empty and we're not a string where """ is a valid value,
            // just return that value.
            if (xml.toString() == "" && !(object is String))
                return object;
            
            return xml.toString();
        }
        
        private function serializeSimple(object:*, xml:XML):void
        {
            xml.appendChild(object.toString());
        }
        
        private function dserializeComplex(object:*, xml:XML, typeHint:String):*
        {
            var isDynamic:Boolean = (object is Array) || (object is Dictionary) || (TypeUtility.isDynamic(object));
            var xmlPath:String = '';			
			
            for each (var fieldXML:XML in xml.*)
            {
                // Figure out the field we're setting, and make sure it is present.
                var fieldName:String = fieldXML.name().toString();
                
                if (!object.hasOwnProperty(fieldName) && !isDynamic)
                {
                    // Try decapitalizing first letter.
                    var decappedFieldName:String = fieldName.charAt(0).toLowerCase() + fieldName.substr(1);
                    
                    if(object.hasOwnProperty(decappedFieldName))
                    {
                        fieldName = decappedFieldName;
                    }
                    else
                    {
                        // Last chance - try to find a match with differing case!
                        var foundOffcaseMatch:Boolean = false;
                        
                        for(var potentialField:String in (object as Object))
                        {
                            if(potentialField.toLowerCase() != fieldName.toLowerCase())
                                continue;
                            
                            fieldName = potentialField;
                            foundOffcaseMatch = true;
                            break;
                        }
                        
                        if(foundOffcaseMatch == false)
                        {
                            xmlPath = reportXMLPath(fieldXML);
                            Logger.warn(object, "deserialize", "The field '" + fieldName + "' does not exist on the class " + TypeUtility.getObjectClassName(object) + ". " + xmlPath);
                            continue;
                        }                    
                        
                    }
                }
                
                // Determine the type.
                var typeName:String = fieldXML.attribute("type");
                if (typeName.length < 1)
                    typeName = TypeUtility.getFieldType(object, fieldName);
                if (isDynamic && typeName == null)
                    typeName = "String";
                
                // deserialize into the child.
                if (!getChildReference(object, fieldName, fieldXML) && !getResourceObject(object, fieldName, fieldXML))
                {
                    var child:* = getChildObject(object, fieldName, typeName, fieldXML);
                    if (child != null)
                    {
                        // Deal with typehints.
                        var childTypeHint:String = TypeUtility.getTypeHint(object, fieldName);
                        child = deserialize(child, fieldXML, childTypeHint);
                    }
                    
                    // Assign the new value.
                    try
                    {
                        object[fieldName] = child;
                    }
                    catch(e:Error)
                    {
                        xmlPath = reportXMLPath(fieldXML);
                        Logger.error(object, "deserialize", "The field " + fieldName + " could not be set to '" + child + "' due to: " + e.toString() + " " + xmlPath);
                    }
                }
            }
            
            return object;
        }
        
        /**
         * Given an XML element, walk up its parent references and show the path
         * in the document, including any name attributes.
         */
        public function reportXMLPath(item:*):String
        {
            // Report each tag and its name attribute if any.
            var path:String = "(";
            
            var stack:Array = [];
            var itemWalk:* = item;
            while(itemWalk)
            {
                stack.unshift(itemWalk);
                itemWalk = itemWalk.parent();
            }
            
            for(var i:int=0; i<stack.length; i++)
            {
                var x:* = stack[i];
                
                path += "<" + x.name().toString();
                
                if(x.hasOwnProperty("@name"))
                    path += " name=\"" + x.@name + "\"";
                
                path += ">"
                
                if(i < stack.length-1)
                    path += " --> ";
            }
            
            path += ")";
            
            return path;
        }
        
        private function serializeComplex(object:*, xml:XML):void
        {
        	if(object==null) return;
        	
            var classDescription:XML = TypeUtility.getTypeDescription(object);
            for each(var property:XML in classDescription.child("accessor"))
            {
                if(property.@access == "readwrite")
                {
                    // Get property info
                    var propertyName:String = property.@name;
                    
                    // Only serialize properties, that aren't null
                    if(object[propertyName] != null)
                    {
                        var propertyXML:XML = serializeProperty(object, propertyName);
                        if(propertyXML != null)
                        {
                            xml.appendChild(propertyXML);
                        }
                    }
                }
            }
            
            for each(var field:XML in classDescription.child("variable"))
            {
                var fieldName:String = field.@name;

                // Only serialize variables, that aren't null
                if(object[fieldName] != null)
                {
                    var fieldXML:XML = serializeProperty(object, fieldName);
                    if(fieldXML != null)
                    {
                        xml.appendChild(fieldXML);
                    }                
                }
            }
        }
        
        private function serializeProperty(object:*, propertyName:String):XML
        {
            var propertyXML:XML = <{propertyName}/>;
            var data:XML = TypeUtility.getEditorData(object, propertyName);

            // Deal with "dynamic" typehints.
            var typeHint:String = TypeUtility.getTypeHint(object, propertyName);
            if(typeHint && typeHint == "dynamic")
            {
                if (!isNaN(object[propertyName]))
                {
                    // Is a number...
                    propertyXML.@type = getQualifiedClassName(1.0).replace(/::/,".");
                }
                else
                {
					// Replace the "::" with "." for a compatible serialization
                    propertyXML.@type = getQualifiedClassName(object[propertyName]).replace(/::/,".");
                }
				
            }
			
            
            
            //Note (giggsy): I don't know why, but this code suddenly didn't compile anymore with FlashDevelop,
            //so I did the rewrite below :/
            //var ignore:XMLList = data ? data.arg.(@key == "ignore") : null;
            //if (ignore && ignore.@value.toString() == "true")
            //   return null;

            // If this field is set to ignore, then ignore it
            if(data)
            {
                var ignore:XMLList = data.arg.(@key == "ignore");
                if(ignore && ignore.@value.toString() == "true")
                    return null;
            }


            // Either make a reference or try to serialize
            if (!setChildReference(object, object[propertyName], propertyXML))
            {
                // OK, we do need to serialize
                serialize(object[propertyName], propertyXML);

                // If the value is the same as the defaultValue, ignore it
                // TODO: Handle simple arrays or structures like Points
                var defaultValue:XMLList = data ? data.arg.(@key == "defaultValue") : null;
                if (defaultValue && object[propertyName].toString() == defaultValue.@value.toString())
                    return null;
            }
            
            return propertyXML;
        }
        
        private function deserializeBoolean(object:*, xml:XML, typeHint:String):*
        {
            return (xml.toString() == "true")
        }
        
        private function serializeBoolean(object:*, xml:XML):void
        {
            if (object)
                xml.appendChild("true");
            else
                xml.appendChild("false");
        }
        
        private function deserializeDictionary(object:*, xml:XML, typeHint:String):*
        {
            for each (var childXML:XML in xml.*)
            {
                // Where are we assigning this item?
                var key:String = childXML.name().toString();
                
                // Deal with escaping numbers and the "add to end" behavior.
                if (key.charAt(0) == "_")
                    key = key.slice(1);
                
                // Might be invalid...
                if ((key.length < 1) && !(object is Array))
                {
                    var xmlPath:String = reportXMLPath(childXML);
                    Logger.error(object, "deserialize", "Cannot add a value to a dictionary without a key. " + xmlPath);
                    continue;
                }
                
                // Infer the type.
                var typeName:String = childXML.attribute("type");
                if (typeName.length < 1)
                    typeName = xml.attribute("childType");
                
                if (typeName == null || typeName == "")
                    typeName = typeHint ? typeHint : "String";
                
                // deserialize the value.
                if (!getChildReference(object, key, childXML) && !getResourceObject(object, key, childXML, typeHint))
                {
                    var value:* = getChildObject(object, key, typeName, childXML);
                    if (value != null)
                        value = deserialize(value, childXML);
                    
                    // Assign, either to key or to end of array.
                    if (key.length > 0)
                        object[key] = value;
                    else
                        (object as Array).push(value);
                }
            }
            
            return object;
        }
        
        private function serializeDictionary(object:*, xml:XML):void
        {
            if (object == null)
                return;

            // Decide if they all share the same type
            var hasType : Boolean = true;
            var anyChild : * = null;
            for each (var child : * in object)
            {
                if (anyChild == null)
                    anyChild = child;
                else if (child != null && TypeUtility.getClass(child) != TypeUtility.getClass(anyChild))
                    hasType = false;
            }
            // If it's empty, we're done
            if (anyChild == null)
                return;

            // Assign child type, if any
            if (hasType)
                xml.@childType = TypeUtility.getObjectClassName(anyChild).replace(/::/,".");

            // Now write all children
            for (var element : * in object)
            {
                // Get the information
                var propertyName : String = (object is Dictionary) ? element : "_";
                var propertyValue : * = object[element];
                var propertyXML:XML = <{propertyName}/>;

                // Write type
                if (!hasType)
                    propertyXML.@type = TypeUtility.getObjectClassName(propertyValue).replace(/::/,".");

                // Write non-entities, or reference entities
                if (!setChildReference(object, propertyValue, propertyXML))
                    serialize(propertyValue, propertyXML);

                // Save
                xml.appendChild(propertyXML);
            }
        }

        private function deserializeClass(object:*, xml:XML, typeHint:String):*
        {
            return TypeUtility.getClassFromName(xml.toString());
        }
        
        /**
         * A tag can have attributes which encode references of various types. This method
         * parses them and resolves the references.
         */ 
        private function getChildReference(object:*, fieldName:String, xml:XML):Boolean
        {
            var nameReference:String = xml.attribute("nameReference");
            var componentReference:String = xml.attribute("componentReference");
            if(!componentReference)
                componentReference = xml.attribute("entityName");
            
            var componentName:String = xml.attribute("componentName");
            var objectReference:String = xml.attribute("objectReference");
            
            if (nameReference != "" || componentReference != "" || componentName != "" || objectReference != "")
            {
                var reference:ReferenceNote = new ReferenceNote();
                reference.owner = object;
                reference.fieldName = fieldName;
                reference.nameReference = nameReference;
                reference.componentReference = componentReference;
                reference.componentName = componentName
                reference.objectReference = objectReference;
                reference.currentEntity = _currentEntity;
                
                if (!reference.resolve())
                    _deferredReferences.push(reference);
                
                return true;
            }
            
            return false;
        }

        /**
         * A tag can have attributes which encode references of various types. This method
         * parses them and resolves the references.
         */ 
        private function setChildReference(object:*, reference:*, xml:XML):Boolean
        {
            // Write entity reference
            if (reference is IEntity)
            {
                xml.@nameReference = (reference as IEntity).name;
                return true;
            }
            // Write component reference
            if (reference is IEntityComponent)
            {
                xml.@entityName = (reference as IEntityComponent).owner.name;
                xml.@componentName = (reference as IEntityComponent).name;
                return true;
            }
            return false;
        }
        
        /**
         * Find or instantiate the value that should go in a named field on an object.
         * 
         * @param object The object which will have the object assigned.
         * @param fieldName The field on the object we are working with.
         * @param typeName The desired type; if different than what is there we replace
         *                 the existing interface.
         */
        private function getChildObject(object:*, fieldName:String, typeName:String, fieldXml:XML):*
        {
            // Get the child object, if it is present.
            var childObject:*;
            try
            {
                childObject = object[fieldName]; 
            } 
            catch(e:Error)
            {
            }
            
            // If requested type isn't the same as what we found, reset the object.
            var desiredType:Class = TypeUtility.getClassFromName(typeName);
            if (!(childObject is desiredType) || !childObject)
                childObject = TypeUtility.instantiate(typeName);
            
            // Note we want to check for null here; null is distinct from coerce-to-false.
            if (childObject == null)
            {
                var xmlPath:String = reportXMLPath(fieldXml);
                Logger.error(object, "deserialize", "Unable to create type " + typeName + " for the field " + fieldName + ". " + xmlPath);
                return null;
            }
            
            return childObject;
        }
        
        private function getResourceObject(object:*, fieldName:String, xml:XML, typeHint:String = null):Boolean
        {
            var filename:String = xml.attribute("filename");
            
            // If attribute is not found, there might be a child tag (depending on what serializer is used.
            if(filename == "")
            {
                filename = xml.child("filename");
            }
            
            if(filename == "")
                return false;
            
            var type:Class = null;
            if(typeHint)
                type = TypeUtility.getClassFromName(typeHint);
            else
                type = TypeUtility.getClassFromName(TypeUtility.getFieldType(object, fieldName));
            
            var resource:ResourceNote = new ResourceNote();
            resource.owner = object;
            resource.fieldName = fieldName;
            resource.load(filename, type);
            
            // we have to hang on to these so they don't get garbage collected
            _resources[filename] = resource;
            return true;
        }
        
        // internal doesn't work here for some reason. It's just being referenced in the ResourceNote support class
        public function removeResource(filename:String):void
        {
            _resources[filename] = null;
            delete _resources[filename];
        }
        
        public function resolveReferences():void
        {
            for (var i:int = 0; i < _deferredReferences.length; i++)
            {
                var reference:ReferenceNote = _deferredReferences[i];
                if (reference.resolve())
                {
                    _deferredReferences.splice(i, 1);
                    i--;
                }
            }
        }
        
        private var _currentEntity:IEntity = null;
        private var _serializers:Dictionary = new Dictionary();
        private var _deserializers:Dictionary = new Dictionary();
        private var _deferredReferences:Array = new Array();
        private var _resources:Dictionary = new Dictionary();
    }
}

import com.pblabs.engine.PBE;
import com.pblabs.engine.core.NameManager;
import com.pblabs.engine.core.TemplateManager;
import com.pblabs.engine.debug.Logger;
import com.pblabs.engine.entity.IEntity;
import com.pblabs.engine.entity.IEntityComponent;
import com.pblabs.engine.resource.Resource;
import com.pblabs.engine.resource.ResourceManager;
import com.pblabs.engine.serialization.*;

internal class ResourceNote
{
    public var owner:* = null;
    public var fieldName:String = null;
    
    public function load(filename:String, type:Class):void
    {
        var resource:Resource = PBE.resourceManager.load(filename, type, onLoaded, onFailed);
        
        if(resource)
            owner[fieldName] = resource;
    }
    
    public function onLoaded(resource:Resource):void
    {
        Serializer.instance.removeResource(resource.filename);
    }
    
    public function onFailed(resource:Resource):void
    {
        Logger.error(owner, "set " + fieldName, "No resource was found with filename " + resource.filename + ".");
        Serializer.instance.removeResource(resource.filename);
    }
}

internal class ReferenceNote
{
    public var owner:* = null;
    public var fieldName:String = null;
    public var nameReference:String = null;
    public var componentReference:String = null;
    public var componentName:String = null;
    public var objectReference:String = null;
    public var currentEntity:IEntity = null;
    public var reportedMissing:Boolean = false;
    
    public function resolve():Boolean
    {
        // Look up by name.
        if (nameReference != "")
        {
            var namedObject:IEntity = PBE.nameManager.lookup(nameReference);
            if (!namedObject)
                return false;
            
            owner[fieldName] = namedObject;
            reportSuccess();
            return true;
        }
        
        // Look up a component on a named object by name (first) or type (second).
        if (componentReference != "")
        {
            var componentObject:IEntity = PBE.nameManager.lookup(componentReference);
            if (!componentObject)
                return false;
            
            var component:IEntityComponent = null;
            if (componentName != "")
            {
                component = componentObject.lookupComponentByName(componentName);
                if (!component)
                    return false;
            }
            else
            {
                var componentType:String = TypeUtility.getFieldType(owner, fieldName);
                component = componentObject.lookupComponentByType(TypeUtility.getClassFromName(componentType));
                if (!component)
                    return false;
            }
            
            owner[fieldName] = component;
            reportSuccess();
            return true;
        }
        
        // Component reference on the entity being deserialized when the reference was created.
        if (componentName != "")
        {
            var localComponent:IEntityComponent = currentEntity.lookupComponentByName(componentName);
            if (!localComponent)
                return false;
            
            owner[fieldName] = localComponent;
            reportSuccess();
            return true;
        }
        
        // Or instantiate a new entity.
        if (objectReference != "")
        {
            owner[fieldName] = PBE.templateManager.instantiateEntity(objectReference);
            reportSuccess();
            return true;
        }
        
        // Nope, none of the above!
        return false;
    }
    
    /**
     * Trigger a console report about any references that haven't been resolved.
     */
    public function reportMissing():void
    {
        // Don't spam.
        if(reportedMissing)
            return;
        reportedMissing = true;
        
        var firstPart:String = owner.toString() + "[" + fieldName + "] on entity '" + currentEntity.name + "' - ";
        
        // Name reference.
        if(nameReference)
        {
            Logger.warn(this, "reportMissing", firstPart + "Couldn't resolve reference to named entity '" + nameReference + "'");
            return; 
        }
        
        // Look up a component on a named object by name (first) or type (second).
        if (componentReference != "")
        {
            Logger.warn(this, "reportMissing", firstPart + " Couldn't find named entity '" + componentReference + "'");
            return;
        }
        
        // Component reference on the entity being deserialized when the reference was created.
        if (componentName != "")
        {
            Logger.warn(this, "reportMissing", firstPart + " Couldn't find component on same entity named '" + componentName + "'");
            return;
        }
    }
    
    private function reportSuccess():void
    {
        // If we succeeded with no spam then be quiet on success too.
        if(!reportedMissing)
            return;
        
        var firstPart:String = owner.toString() + "[" + fieldName + "] on entity '" + currentEntity.name + "' - ";
        
        // Name reference.
        if(nameReference)
        {
            Logger.warn(this, "reportSuccess", firstPart + " After failure, was able to resolve reference to named entity '" + nameReference + "'");
            return; 
        }
        
        // Look up a component on a named object by name (first) or type (second).
        if (componentReference != "")
        {
            Logger.warn(this, "reportSuccess", firstPart + " After failure, was able to find named entity '" + componentReference + "'");
            return;
        }
        
        // Component reference on the entity being deserialized when the reference was created.
        if (componentName != "")
        {
            Logger.warn(this, "reportSuccess", firstPart + " After failure, was able to find component on same entity named '" + componentName + "'");
            return;
        }
    }
}
