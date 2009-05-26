/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Engine.Core
{
   import PBLabs.Engine.Entity.IEntity;
   import PBLabs.Engine.Debug.Logger;
   import PBLabs.Engine.Serialization.*;
   import PBLabs.Engine.Resource.*;
   
   import flash.events.*
   import flash.utils.Dictionary;
   
   /**
    * @eventType PBLabs.Engine.Core.LevelEvent.READY_EVENT
    */
   [Event(name="READY_EVENT", type="PBLabs.Engine.Core.LevelEvent")]
   
   /**
    * @eventType PBLabs.Engine.Core.LevelEvent.LEVEL_LOADED_EVENT
    */
   [Event(name="LEVEL_LOADED_EVENT", type="PBLabs.Engine.Core.LevelEvent")]
   
   /**
    * @eventType PBLabs.Engine.Core.LevelEvent.LEVEL_UNLOADED_EVENT
    */
   [Event(name="LEVEL_UNLOADED_EVENT", type="PBLabs.Engine.Core.LevelEvent")]
   
   /**
    * The LevelManager allows level files and groups to be added to a specific level so they
    * can be automatically managed when that level is loaded or unloaded.
    * 
    * @see PBLabs.Engine.MXML.LevelFileReference
    * @see PBLabs.Engine.MXML.GroupReference
    */
   public class LevelManager extends EventDispatcher implements ISerializable
   {
      /**
       * The singleton LevelManager instance.
       */
      public static function get Instance():LevelManager
      {
         if (_instance == null)
            _instance = new LevelManager();
         
         return _instance;
      }
      
      private static var _instance:LevelManager = null;
      
      /**
       * The level that is currently loaded.
       */
      public function get CurrentLevel():int
      {
         if (_isLevelLoaded)
            return _currentLevel;
         
         return -1;
      }
      
      /**
       * With this method, you can override the default file loading methods by having
       * custom functions called instead of the defaults.
       * 
       * @param load The function to call to load files
       * @param unload The function to call to unload files
       */
      public function SetLoadFileCallbacks(load:Function, unload:Function):void
      {
         _loadFileCallback = load;
         _unloadFileCallback = unload;
      }
      
      /**
       * With this method, you can override the default group loading methods by having
       * custom functions called instead of the defaults.
       * 
       * @param load The function to call to load groups
       * @param unload The function to call to unload groups
       */
      public function SetLoadGroupCallbacks(load:Function, unload:Function):void
      {
         _loadGroupCallback = load;
         _unloadGroupCallback = unload;
      }
      
      /**
       * Starts up the LevelManager. This is automatically called if level descriptions are loaded
       * from a file with the Load method. Otherwise, this should be called after all the level
       * data has been registered with AddFileReference and AddGroupReference. When everything is
       * ready (except for the initialLevel loading), LevelEvent.READY_EVENT is dispatched.
       * 
       * @param initialLevel The level to load once everything is set up
       */
      public function Start(initialLevel:int=-1):void
      {
         if (_isReady)
         {
            Logger.PrintError(this, "Start", "The LevelManager has already been started.");
            return;
         }
         
         TemplateManager.Instance.addEventListener(TemplateManager.LOADED_EVENT, _OnFileLoaded);
         TemplateManager.Instance.addEventListener(TemplateManager.FAILED_EVENT, _OnFileLoadFailed);
         
         _isReady = true;
         dispatchEvent(new LevelEvent(LevelEvent.READY_EVENT, -1));
         
         if (initialLevel != -1)
            LoadLevel(initialLevel);
      }
      
      /**
       * Starts up the level manager and loads level description data from an xml file. Start is
       * automatically called when this finishes.
       * 
       * @param filename The file to load level descriptions from
       * @param initialLevel The level to load once everything is set up
       */
      public function Load(filename:String, initialLevel:int=-1):void
      {
         if (_isReady)
         {
            Logger.PrintError(this, "Load", "The LevelManager has already been started.");
            return;
         }
         
         _initialLevel = initialLevel;
         ResourceManager.Instance.Load(filename, XMLResource, _OnLevelDescriptionsLoaded, _OnLevelDescriptionsLoadFailed);
      }
      
      private function _OnLevelDescriptionsLoaded(resource:XMLResource):void
      {
         Serializer.Instance.Deserialize(this, resource.XMLData);
      }
      
      private function _OnLevelDescriptionsLoadFailed(resource:XMLResource):void
      {
         Logger.PrintError(this, "Load", "Failed to load level descriptions file " + resource.Filename + "!");
      }
      
      /**
       * @inheritDoc
       */
      public function Serialize(xml:XML):void
      {
         for each (var levelDescription:LevelDescription in _levelDescriptions)
         {
            var levelXML:XML = <level/>;
            levelXML.@index = levelDescription.Index;
            levelXML.@name = levelDescription.Name;
            
            for each (var filename:String in levelDescription.Files)
               levelXML.appendChild(<file name={filename}/>);
            
            for each (var groupName:String in levelDescription.Groups)
               levelXML.appendChild(<group name={groupName}/>);
         }
      }
      
      /**
       * @inheritDoc
       */
      public function Deserialize(xml:XML):*
      {
         for each (var levelDescriptionXML:XML in xml.*)
         {
            var index:int = levelDescriptionXML.@index;
            
            var levelDescription:LevelDescription = new LevelDescription();
            levelDescription.Index = index;
            levelDescription.Name = levelDescriptionXML.@name;
            _levelDescriptions[index] = levelDescription;
            
            for each (var itemXML:XML in levelDescriptionXML.*)
            {
               if (itemXML.name() == "file")
                  AddFileReference(index, itemXML.@filename);
               else if (itemXML.name() == "group")
                  AddGroupReference(index, itemXML.@name);
               else
                  Logger.PrintError(this, "Load", "Encountered unknown tag " + itemXML.name() + " in level description.");
            }
         }
         
         Start(_initialLevel);
      }
      
      /**
       * NOT IMPLEMENTED! The intention is to have the level manager serialize everything that is
       * currently loaded to xml.
       */
      public function SaveState(xml:XML):void
      {
         if (!_isLevelLoaded)
         {
            Logger.PrintError(this, "SaveState", "Cannot save state. No level is loaded.");
            return;
         }
         
         throw new Error("Not implemented!");
      }
      
      /**
       * NOT IMPLEMENTED! The intention is to have the level manager deserialize saved data from an
       * xml file.
       */
      public function LoadState(xml:XML):void
      {
         if (!_isReady)
         {
            Logger.PrintError(this, "LoadState", "Cannot load state. The LevelManager has not been started.");
            return;
         }
         
         throw new Error("Not implemented!");
      }
      
      /**
       * Loads an entity with the TemplateManager and tracks it. If the current level ends before the
       * entity is destroyed, it will be destroyed automatically.
       * 
       * @param name The name of the entity to instantiate.
       * 
       * @return The created entity.
       */
      public function LoadEntity(name:String):IEntity
      {
         if (!_isReady)
         {
            Logger.PrintError(this, "LoadEntity", "Cannot load entities. The LevelManager has not been started.");
            return null;
         }
         
         if (!_isLevelLoaded)
         {
            Logger.PrintError(this, "LoadEntity", "Cannot load entities. No level is loaded.");
            return null;
         }
         
         var entity:IEntity = TemplateManager.Instance.InstantiateEntity(name);
         if (entity == null)
         {
            Logger.PrintError(this, "LoadEntity", "Failed to instantiate an entity with name " + name + ".");
            return null;
         }
         
         entity.EventDispatcher.addEventListener("EntityDestroyed", _OnEntityDestroyed);
         _loadedEntities.push(entity);
         
         return entity;
      }
      
      /**
       * Loads the specified level and unloads any previous levels. If the previous level and the new
       * level share data, it will not be reloaded.
       * 
       * @param index The level number to load.
       */
      public function LoadLevel(index:int):void
      {
         if (!_HasLevelData(index))
         {
            Logger.PrintError(this, "LoadLevel", "Level data for level " + index + " does not exist.");
            return;
         }
         
         // find file differences between the levels
         var filesToLoad:Array = new Array();
         var filesToUnload:Array = new Array();
         
         var doUnload:Boolean = _isLevelLoaded && (_currentLevel != 0);
         _GetLoadLists(doUnload ? _levelDescriptions[_currentLevel].Files : null, _levelDescriptions[index].Files, filesToLoad, filesToUnload);
         
         // find group differences between the levels
         _groupsToLoad = new Array();
         var groupsToUnload:Array = new Array();
         _GetLoadLists(doUnload ? _levelDescriptions[_currentLevel].Groups : null, _levelDescriptions[index].Groups, _groupsToLoad, groupsToUnload);
         
         // unload previous data
         _Unload(filesToUnload, groupsToUnload);
         dispatchEvent(new LevelEvent(LevelEvent.LEVEL_UNLOADED_EVENT, _currentLevel));
         
         _currentLevel = index;
         _isLevelLoaded = true;
         
         // load files - setting this to one ensures all files will be queued up before loading continues
         _pendingFiles = 1;
         for each (var filename:String in filesToLoad)
         {
            _pendingFiles++;
            if (_loadFileCallback != null)
               _loadFileCallback(filename, _FinishLoad)
            else
               TemplateManager.Instance.LoadFile(filename);
         }
         
         _FinishLoad();
      }
      
      private function _OnFileLoaded(event:Event):void
      {
         _FinishLoad();
      }
      
      private function _OnFileLoadFailed(event:Event):void
      {
         Logger.PrintError(this, "LoadLevel", "One of the files for level " + _currentLevel + " failed to load.");
         _FinishLoad();
      }
      
      private function _FinishLoad():void
      {
         _pendingFiles--;
         if (_pendingFiles > 0)
            return;
         
         // load groups
         for each (var groupName:String in _groupsToLoad)
         {
            if (_loadGroupCallback != null)
            {
               _loadGroupCallback(groupName);
               continue;
            }
            
            var groupEntities:Array = TemplateManager.Instance.InstantiateGroup(groupName);
            if (groupEntities == null)
            {
               Logger.PrintError(this, "LoadLevel", "Failed to instantiate the group " + groupName + ".");
               continue;
            }
            
            _loadedGroups[groupName] = new Array();
            for each (var groupEntity:IEntity in groupEntities)
               _loadedGroups[groupName].push(groupEntity);
         }
         
         _groupsToLoad = null;
         dispatchEvent(new LevelEvent(LevelEvent.LEVEL_LOADED_EVENT, _currentLevel));
      }
      
      /**
       * Loads the next level after the current level.
       */
      public function LoadNextLevel():void
      {
         LoadLevel(_currentLevel + 1);
      }
      
      /**
       * Unloads all the currently loaded data. Do not use this when another level is being loaded. Allow
       * the Load method to handle unloading old data.
       */
      public function UnloadCurrentLevel():void
      {
         if (!_isLevelLoaded)
         {
            Logger.PrintError(this, "UnloadCurrentLevel", "No level is loaded.");
            return;
         }
         
         var filesToUnload:Array = new Array();
         _GetLoadLists(_levelDescriptions[_currentLevel].Files, null, null, filesToUnload);
         
         var groupsToUnload:Array = new Array();
         _GetLoadLists(_levelDescriptions[_currentLevel].Groups, null, null, groupsToUnload);
         
         _Unload(filesToUnload, groupsToUnload);
         dispatchEvent(new LevelEvent(LevelEvent.LEVEL_UNLOADED_EVENT, _currentLevel));
         
         _currentLevel = -1;
         _isLevelLoaded = false;
      }
      
      private function _Unload(filesToUnload:Array, groupsToUnload:Array):void
      {
         // cleanup extra loaded stuff
         for each (var extraEntity:IEntity in _loadedEntities)
         {
            extraEntity.EventDispatcher.removeEventListener("EntityDestroyed", _OnEntityDestroyed);
            extraEntity.Destroy();
         }
         
         _loadedEntities.splice(0, _loadedEntities.length);
         
         // unload groups
         for each (var groupName:String in groupsToUnload)
         {
            if (_unloadGroupCallback != null)
            {
               _unloadGroupCallback(groupName);
               continue;
            }
            
            for each (var groupEntity:IEntity in _loadedGroups[groupName])
               groupEntity.Destroy();
            
            _loadedGroups[groupName] = null;
            delete _loadedGroups[groupName];
         }
         
         // unload files
         for each (var filename:String in filesToUnload)
         {
            if (_unloadFileCallback != null)
            {
               _unloadFileCallback(filename);
               continue;
            }
            
            TemplateManager.Instance.UnloadFile(filename);
            _loadedFiles[filename] = null;
            delete _loadedFiles[filename];
         }
      }
      
      private function _GetLoadLists(previousList:Array, nextList:Array, loadList:Array, unloadList:Array):void
      {
         if (nextList != null)
         {
            for each (var loadName:String in nextList)
            {
               // if it's in the previous list, don't need to load it
               if ((previousList != null) && (previousList.indexOf(loadName) != -1))
                  continue;
            
               loadList.push(loadName);
            }
         }
         
         if (previousList != null)
         {
            for each (var unloadName:String in previousList)
            {
               // if it's in the next list, don't need to unload it
               if ((nextList != null) && (nextList.indexOf(unloadName) != -1))
                  continue;
            
               unloadList.push(unloadName);
            }
         }
      }
      
      private function _OnEntityDestroyed(event:Event):void
      {
      }
      
      /**
       * Register a file with a level number. The same file can be registered with several levels.
       * 
       * @param index The level to register with
       * @param filename The file to register
       */
      public function AddFileReference(index:int, filename:String):void
      {
         if (_isLevelLoaded && (_currentLevel == index))
         {
            Logger.PrintError(this, "AddFileReference", "Cannot add level information to a level that is loaded.");
            return;
         }
         
         var levelDescription:LevelDescription = _GetLevelDescription(index);
         levelDescription.Files.push(filename);
      }
      
      /**
       * Register a group with a level number. The same group can be registered with several levels.
       * 
       * @param index The level to register with
       * @param name The name of the group to register
       */
      public function AddGroupReference(index:int, name:String):void
      {
         if (_isLevelLoaded && (_currentLevel == index))
         {
            Logger.PrintError(this, "AddGroupReference", "Cannot add level information to a level that is loaded.");
            return;
         }
         
         var levelDescription:LevelDescription = _GetLevelDescription(index);
         levelDescription.Groups.push(name);
      }
      
      private function _GetLevelDescription(index:int):LevelDescription
      {
         var levelDescription:LevelDescription = _levelDescriptions[index];
         if (levelDescription == null)
         {
            levelDescription = new LevelDescription();
            levelDescription.Index = index;
            _levelDescriptions[index] = levelDescription;
         }
         
         return levelDescription;
      }
      
      private function _HasLevelData(index:int):Boolean
      {
         return _levelDescriptions[index] != null;
      }
      
      private var _initialLevel:int = -1;
      private var _isReady:Boolean = false;
      private var _isLevelLoaded:Boolean = false;
      private var _currentLevel:int = 0;
      private var _levelDescriptions:Array = new Array();
      
      private var _pendingFiles:int = 0;
      private var _groupsToLoad:Array;
      
      // array of filenames
      private var _loadedFiles:Array = new Array();
      
      // dictionary of group names to array of entities
      private var _loadedGroups:Dictionary = new Dictionary();
      
      // array of entities
      private var _loadedEntities:Array = new Array();
      
      private var _loadFileCallback:Function = null;
      private var _unloadFileCallback:Function = null;
      private var _loadGroupCallback:Function = null;
      private var _unloadGroupCallback:Function = null;
   }
}

class LevelDescription
{
   public var Name:String = "";
   public var Index:int = 0;
   
   public var Files:Array = new Array();
   public var Groups:Array = new Array();
}