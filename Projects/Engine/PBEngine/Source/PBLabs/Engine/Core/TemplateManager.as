package PBLabs.Engine.Core
{
   import PBLabs.Engine.Entity.AllocateEntity;
   import PBLabs.Engine.Entity.IEntity;
   import PBLabs.Engine.Debug.Logger;
   import PBLabs.Engine.Resource.ResourceManager;
   import PBLabs.Engine.Resource.XMLResource;
   import PBLabs.Engine.Serialization.Serializer;
   import PBLabs.Engine.Serialization.TypeUtility;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   /**
    * The template manager loads and unloads level files and stores information
    * about their contents. The Serializer is used to deserialize object
    * descriptions.
    * 
    * <p>A level file can contain templates, entities, and groups. A template
    * describes an entity that will be instantiated several times, like a
    * bullet. Templates are left unnamed when they are instantiated.</p>
    * 
    * <p>An entity describes a complete entity that is only instantiated once, like
    * a background tilemap. Entities are named based on the name of the xml data
    * that describes it.</p>
    * 
    * <p>A group contains references to templates, entities, and other groups that
    * should be instantiated when the group is instantiated.</p>
    * 
    * @see PBLabs.Engine.Serialization.Serializer.
    * @see ../../../../../Reference/XMLFormat.html The XML Format
    * @see ../../../../../Reference/Levels.html Levels
    */
   public class TemplateManager extends EventDispatcher
   {
      /**
       * Defines the event to dispatch when a level file is successfully loaded.
       */
      public static const LOADED_EVENT:String = "LOADED_EVENT";
      
      /**
       * Defines the event to dispatch when a level file fails to load.
       */
      public static const FAILED_EVENT:String = "FAILED_EVENT";
      
      /**
       * The singleton TemplateManager instance.
       */
      public static function get Instance():TemplateManager
      {
         if (_instance == null)
            _instance = new TemplateManager();
         
         return _instance;
      }
      
      private static var _instance:TemplateManager = null;
      
      public function set EntityType(type:Class):void
      {
         _entityType = type;
      }
      
      /**
       * Loads a level file and adds its contents to the template manager. This
       * does not instantiate any of the objects in the file, it merely loads
       * them for future instantiation.
       * 
       * <p>When the load completes, the LOADED_EVENT will be dispatched. If
       * the load fails, the FAILED_EVENT will be dispatched.</p>
       * 
       * @param filename The file to load.
       */
      public function LoadFile(filename:String):void
      {
         ResourceManager.Instance.Load(filename, XMLResource, _OnLoaded, _OnFailed);
      }
      
      /**
       * Unloads a level file and removes its contents from the template manager.
       * This does not destroy any entities that have been instantiated.
       * 
       * @param filename The file to unload.
       */
      public function UnloadFile(filename:String):void
      {
         RemoveXML(filename);
         ResourceManager.Instance.Unload(filename);
      }
      
      /**
       * Creates an instance of an object with the specified name. The name must
       * refer to a template or entity. To instantiate groups, use InstantiateGroup
       * instead.
       * 
       * @param name The name of the entity or template to instantiate. This
       * corresponds to the name attribute on the template or entity tag in the XML.
       * 
       * @return The created entity, or null if it wasn't found.
       */
      public function InstantiateEntity(name:String):IEntity
      {
         var xml:XML = GetXML(name, "template", "entity");
         if (xml == null)
         {
            Logger.PrintError(this, "InstantiateEntity", "Unable to find a template or entity with the name " + name + ".");
            return null;
         }
         
         var name:String = xml.attribute("name");
         if (xml.name() == "template")
            name = "";
         
         var entity:IEntity;
         if (_entityType == null)
            entity = AllocateEntity();
         else
            entity = new _entityType();
         
         entity.Initialize(name);
         
         if (!_InstantiateTemplate(entity, xml.attribute("template"), new Dictionary()))
         {
            entity.Destroy();
            return null;
         }
         
         Serializer.Instance.Deserialize(entity, xml);
         return entity;
      }
      
      /**
       * Instantiates all templates or entities referenced by the specified group.
       * 
       * @param name The name of the group to instantiate. This correspands to the
       * name attribute on the group tag in the XML.
       * 
       * @return An array containing all the instantiated objects. If the group
       * wasn't found, the array will be empty.
       */
      public function InstantiateGroup(name:String):Array
      {
         var group:Array = new Array();
         if (!_InstantiateGroup(name, group, new Dictionary()))
         {
            for each (var entity:IEntity in group)
               entity.Destroy();
            
            return null;
         }
         
         return group;
      }
      
      /**
       * Adds an XML description of a template, entity, or group to the template manager so
       * it can be instantiated in the future.
       * 
       * @param xml The xml to add.
       * @param identifier A string by which this xml can be referenced. This is NOT the
       * name of the object. It is used so the xml can be removed by a call to RemoveXML.
       * @param version The version of the format of the added xml.
       */
      public function AddXML(xml:XML, identifier:String, version:int):void
      {
         var name:String = xml.attribute("name");
         if (name.length == 0)
         {
            Logger.PrintWarning(this, "AddXML", "XML object description added without a 'name' attribute.");
            return;
         }
         
         if (_xmlObjects[name] != null)
         {
            Logger.PrintWarning(this, "AddXML", "An XML object description with name " + name + " has already been added.");
            return;
         }
         
         var thing:ThingReference = new ThingReference();
         thing.XMLData = xml;
         thing.Identifier = identifier;
         thing.Version = version;
         
         _xmlObjects[name] = thing;
      }
      
      /**
       * Removes the specified object from the template manager.
       * 
       * @param identifier This is NOT the name of the xml object. It is the value
       * passed as the identifier in AddXML.
       */
      public function RemoveXML(identifier:String):void
      {
         for (var name:String in _xmlObjects)
         {
            var thing:ThingReference = _xmlObjects[name];
            if (thing.Identifier == identifier)
            {
               _xmlObjects[name] = null;
               delete _xmlObjects[name];
            }
         }
      }
      
      /**
       * Gets a previously added xml description that has the specified name.
       * 
       * @param name The name of the xml to retrieve.
       * @param xmlType1 The type (template, entity, or group) the xml must be.
       * If this is null, it can be anything.
       * @param xmlType2 Another type (template, entity, or group) the xml can
       * be.
       * 
       * @return The xml description with the specified name, or null if it wasn't
       * found.
       */
      public function GetXML(name:String, xmlType1:String = null, xmlType2:String = null):XML
      {
         var thing:ThingReference = _GetXML(name, xmlType1, xmlType2);
         return thing != null ? thing.XMLData : null;
      }
      
      private function _GetXML(name:String, xmlType1:String, xmlType2:String):ThingReference
      {
         var thing:ThingReference = _xmlObjects[name];
         if (thing == null)
            return null;
         
         if (xmlType1 != null)
         {
            var type:String = thing.XMLData.name();
            if ((type != xmlType1) && (type != xmlType2))
               return null;
         }
         
         return thing;
      }
      
      private function _InstantiateTemplate(object:IEntity, templateName:String, tree:Dictionary):Boolean
      {
         if ((templateName == null) || (templateName.length == 0))
            return true;
         
         if (tree[templateName] != null)
         {
            Logger.PrintWarning(this, "InstantiateTemplate", "Cyclical template detected. " + templateName + " has already been instantiated.");
            return false;
         }
         
         var templateXML:XML = GetXML(templateName, "template");
         if (templateXML == null)
         {
            Logger.PrintWarning(this, "Instantiate", "Unable to find the template " + templateName + ".");
            return false;
         }
         
         tree[templateName] = true;
         if (!_InstantiateTemplate(object, templateXML.attribute("template"), tree))
            return false;
         
         object.Deserialize(templateXML, false);
         return true;
      }
      
      private function _InstantiateGroup(name:String, group:Array, tree:Dictionary):Boolean
      {
         var xml:XML = GetXML(name, "group");
         if (xml == null)
            return true;
         
         for each(var objectXML:XML in xml.*)
         {
            var childName:String = objectXML.attribute("name");
            if (objectXML.name() == "groupReference")
            {
               if (tree[childName] != null)
               {
                  Logger.PrintWarning(this, "InstantiateGroup", "Cyclical group detected. " + childName + " has already been instantiated.");
                  return false;
               }
               
               tree[childName] = true;
               if (!_InstantiateGroup(childName, group, tree))
                  return false;
            }
            else if (objectXML.name() == "objectReference")
            {
               group.push(InstantiateEntity(childName));
            }
            else
            {
               Logger.PrintWarning(this, "InstantiateGroup", "Encountered unknown tag " + objectXML.name() + " in group.");
            }
         }
         
         return true;
      }
      
      private function _OnLoaded(resource:XMLResource):void
      {
         var version:int = resource.XMLData.attribute("version");
         for each(var xml:XML in resource.XMLData.*)
            AddXML(xml, resource.Filename, version);
         
         dispatchEvent(new Event(LOADED_EVENT));
      }
      
      private function _OnFailed(resource:XMLResource):void
      {
         dispatchEvent(new Event(FAILED_EVENT));
      }
      
      private var _entityType:Class = null;
      private var _xmlObjects:Dictionary = new Dictionary();
   }
}

class ThingReference
{
   public var Version:int = 0;
   public var XMLData:XML = null;
   public var Identifier:String = "";
}