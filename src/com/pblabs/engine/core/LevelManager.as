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
   import com.pblabs.engine.debug.Logger;
   import com.pblabs.engine.entity.IEntity;
   import com.pblabs.engine.resource.ResourceManager;
   import com.pblabs.engine.resource.XMLResource;
   import com.pblabs.engine.serialization.ISerializable;
   import com.pblabs.engine.serialization.Serializer;
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;

   /**
    * @eventType com.pblabs.engine.core.LevelEvent.READY_EVENT
    */
   [Event(name="READY_EVENT", type="com.pblabs.engine.core.LevelEvent")]
   
   /**
    * @eventType com.pblabs.engine.core.LevelEvent.LEVEL_LOADED_EVENT
    */
   [Event(name="LEVEL_LOADED_EVENT", type="com.pblabs.engine.core.LevelEvent")]
   
   /**
    * @eventType com.pblabs.engine.core.LevelEvent.LEVEL_UNLOADED_EVENT
    */
   [Event(name="LEVEL_UNLOADED_EVENT", type="com.pblabs.engine.core.LevelEvent")]
   
   /**
    * The LevelManager allows level files and groups to be added to a specific level so they
    * can be automatically managed when that level is loaded or unloaded.
    * 
    * @see com.pblabs.engine.mxml.LevelFileReference
    * @see com.pblabs.engine.mxml.GroupReference
    */
   public class LevelManager extends EventDispatcher implements ISerializable
   {
      /**
       * The singleton LevelManager instance.
       */
      public static function get instance():LevelManager
      {
         if (!_instance)
            _instance = new LevelManager();
         
         return _instance;
      }
      
      private static var _instance:LevelManager = null;
      
      /**
       * The level that is currently loaded.
       */
      public function get currentLevel():int
      {
         if (_isLevelLoaded)
            return _currentLevel;
         
         return -1;
      }
      
      /**
       * Returns the number of levels the LevelManager has data for.
       */
      public function get levelCount():int
      {
         var count:int = 0;
         for each (var level:LevelDescription in _levelDescriptions)
            count++;
         
         return count;
      }
      
      /**
       * Gets an array of filenames that are to be loaded with a specific level.
       */
      public function getlevelFiles(index:int):Array
      {
         return _levelDescriptions[index].Files;
      }
      
      /**
       * Gets an array of group names that are to be loaded with a specific level.
       */
      public function getlevelGroups(index:int):Array
      {
         return _levelDescriptions[index].Groups;
      }
	  
	  /**
	   * Gets a level index based on the registered level name.  Case sensitive.
	   * 
	   * Returns -1 if the level name is not found.
	   */ 
	  public function getlevelIndexByName(levelName:String):int
	  {
		 for each (var level:LevelDescription in _levelDescriptions)
		 {
			 if (level.name == levelName) {
				 return level.index;
			 }
		 }
		 
		 return -1;
	  }
      
      /**
       * With this method, you can override the default file loading methods by having
       * custom functions called instead of the defaults.
       * 
       * @param load The function to call to load files
       * @param unload The function to call to unload files
       */
      public function setLoadFileCallbacks(load:Function, unload:Function):void
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
      public function setLoadGroupCallbacks(load:Function, unload:Function):void
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
      public function start(initialLevel:int=-1):void
      {
         if (_isReady)
         {
            Logger.error(this, "Start", "The LevelManager has already been started.");
            return;
         }
         
         PBE.templateManager.addEventListener(TemplateManager.LOADED_EVENT, onFileLoaded);
         PBE.templateManager.addEventListener(TemplateManager.FAILED_EVENT, onFileLoadFailed);
         
         _isReady = true;
         dispatchEvent(new LevelEvent(LevelEvent.READY_EVENT, -1));
         
         if (initialLevel != -1)
            loadLevel(initialLevel);
      }
      
      /**
       * Starts up the level manager and loads level description data from an xml file. Start is
       * automatically called when this finishes.
       * 
       * @param filename The file to load level descriptions from
       * @param initialLevel The level to load once everything is set up
       */
      public function load(filename:String, initialLevel:int=-1):void
      {
         if (_isReady)
         {
            Logger.error(this, "Load", "The LevelManager has already been started.");
            return;
         }
         
         _initialLevel = initialLevel;
         PBE.resourceManager.load(filename, XMLResource, onLevelDescriptionsLoaded, onLevelDescriptionsLoadFailed);
      }
      
      private function onLevelDescriptionsLoaded(resource:XMLResource):void
      {
         Serializer.instance.deserialize(this, resource.XMLData);
         Logger.print(this, "Loaded " + _levelDescriptions.length + " level descriptions.");
      }
      
      private function onLevelDescriptionsLoadFailed(resource:XMLResource):void
      {
         if (resource)
         {
            Logger.error(this, "Load", "Failed to load level descriptions file " + resource.filename + "!");    }
         else
         {
            Logger.error(this, "Load", "Failed to load level descriptions file!");
         }
      }
      
      /**
       * Unload the current level.
       */
      public function clear():void
      {
         unloadCurrentLevel();
         
         _currentLevel = 0;
         _levelDescriptions = new Array();
         _isReady = false;
      }
      
      /**
       * @inheritDoc
       */
      public function serialize(xml:XML):void
      {
         for each (var levelDescription:LevelDescription in _levelDescriptions)
         {
            var levelXML:XML = <level/>;
            levelXML.@index = levelDescription.index;
            levelXML.@name = levelDescription.name;
            
            for each (var filename:String in levelDescription.files)
               levelXML.appendChild(<file filename={filename}/>);
            
            for each (var groupName:String in levelDescription.groups)
               levelXML.appendChild(<group name={groupName}/>);
               
            xml.appendChild(levelXML);
         }
      }
      
      /**
       * @inheritDoc
       */
      public function deserialize(xml:XML):*
      {
         for each (var levelDescriptionXML:XML in xml.*)
         {
            var index:int = levelDescriptionXML.@index;
            
            var levelDescription:LevelDescription = new LevelDescription();
            levelDescription.index = index;
            levelDescription.name = levelDescriptionXML.@name;
            _levelDescriptions[index] = levelDescription;
            
            for each (var itemXML:XML in levelDescriptionXML.*)
            {
               if (itemXML.name() == "file")
                  addFileReference(index, itemXML.@filename);
               else if (itemXML.name() == "group")
                  addGroupReference(index, itemXML.@name);
               else
                  Logger.error(this, "Load", "Encountered unknown tag " + itemXML.name() + " in level description.");
            }
         }
         
         start(_initialLevel);
      }
      
      /**
       * Loads an entity with the TemplateManager and tracks it. If the current level ends before the
       * entity is destroyed, it will be destroyed automatically.
       * 
       * @param name The name of the entity to instantiate.
       * 
       * @return The created entity.
       */
      public function loadEntity(name:String):IEntity
      {
         if (!_isReady)
         {
            Logger.error(this, "loadEntity", "Cannot load entities. The LevelManager has not been started.");
            return null;
         }
         
         if (!_isLevelLoaded)
         {
            Logger.error(this, "loadEntity", "Cannot load entities. No level is loaded.");
            return null;
         }
         
         var entity:IEntity = PBE.templateManager.instantiateEntity(name);
         if (!entity)
         {
            Logger.error(this, "loadEntity", "Failed to instantiate an entity with name " + name + ".");
            return null;
         }
         
         entity.eventDispatcher.addEventListener("EntityDestroyed", onEntityDestroyed);
         _loadedEntities.push(entity);
         
         return entity;
      }
      
      /**
       * Loads the specified level and unloads any previous levels. If the previous level and the new
       * level share data, it will not be reloaded.
       * 
       * @param index The level number to load.
	   * @param force Force reload.
       */
      public function loadLevel(index:int, force:Boolean = false):void
      {
          if(!_isReady)
          {
              Logger.warn(this, "loadLevel", "Warning: trying to loadLevel() without having first called start()! This probably won't work." );
          }
          
         if (!hasLevelData(index))
         {
            Logger.error(this, "loadLevel", "Level data for level " + index + " does not exist.");
            return;
         }
		 
         // find file differences between the levels
         var filesToLoad:Array = new Array();
         var filesToUnload:Array = new Array();
         var groupsToUnload:Array = new Array();
         
         if (force)
         {
             filesToLoad = _levelDescriptions[index].files;
             _groupsToLoad = _levelDescriptions[index].groups;

             if (_levelDescriptions[_currentLevel]) {
                 filesToUnload = _levelDescriptions[_currentLevel].files;
                 groupsToUnload = _levelDescriptions[_currentLevel].groups;
             }
             
         }
         else
         {
             var doUnload:Boolean = _isLevelLoaded && (_currentLevel != 0);
             getLoadLists(doUnload ? _levelDescriptions[_currentLevel].files : null, _levelDescriptions[index].files, filesToLoad, filesToUnload);
             
             // find group differences between the levels
             _groupsToLoad = new Array();
             
             getLoadLists(doUnload ? _levelDescriptions[_currentLevel].groups : null, _levelDescriptions[index].groups, _groupsToLoad, groupsToUnload);
         }

         // unload previous data
         unload(filesToUnload, groupsToUnload);
         dispatchEvent(new LevelEvent(LevelEvent.LEVEL_UNLOADED_EVENT, _currentLevel));
         
         _currentLevel = index;
         _isLevelLoaded = true;
         
         // load files - setting this to one ensures all files will be queued up before loading continues
         _pendingFiles = 1;
         for each (var filename:String in filesToLoad)
         {
            _pendingFiles++;
            if (_loadFileCallback != null)
               _loadFileCallback(filename, finishLoad)
            else
               PBE.templateManager.loadFile(filename, force);
         }
         
         finishLoad();
      }
      
      private function onFileLoaded(event:Event):void
      {
         finishLoad();
      }
      
      private function onFileLoadFailed(event:Event):void
      {
         Logger.error(this, "LoadLevel", "One of the files for level " + _currentLevel + " failed to load.");
         finishLoad();
      }
      
      private function finishLoad():void
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
            
            var groupEntities:Array = PBE.templateManager.instantiateGroup(groupName);
            if (!groupEntities)
            {
               Logger.error(this, "LoadLevel", "Failed to instantiate the group " + groupName + ".");
               continue;
            }
            
            _loadedGroups[groupName] = new Array();
            for each (var groupEntity:IEntity in groupEntities)
			{
               _loadedGroups[groupName].push(groupEntity);
			}
         }
         
         _groupsToLoad = null;
         dispatchEvent(new LevelEvent(LevelEvent.LEVEL_LOADED_EVENT, _currentLevel));
      }
      
      /**
       * Loads the next level after the current level.
       */
      public function loadNextLevel():void
      {
         loadLevel(_currentLevel + 1);
      }
      
      /**
       * Unloads all the currently loaded data. Do not use this when another level is being loaded. Allow
       * the load() method to handle unloading old data.
       */
      public function unloadCurrentLevel():void
      {
         if (!_isLevelLoaded)
         {
            Logger.error(this, "UnloadCurrentLevel", "No level is loaded.");
            return;
         }
         
         var filesToUnload:Array = new Array();
         getLoadLists(_levelDescriptions[_currentLevel].files, null, null, filesToUnload);
         
         var groupsToUnload:Array = new Array();
         getLoadLists(_levelDescriptions[_currentLevel].groups, null, null, groupsToUnload);
         
         unload(filesToUnload, groupsToUnload);
         //dispatchEvent(new LevelEvent(LevelEvent.LEVEL_UNLOADED_EVENT, _currentLevel));
         
         _currentLevel = -1;
         _isLevelLoaded = false;
		 
		 dispatchEvent(new LevelEvent(LevelEvent.LEVEL_UNLOADED_EVENT, _currentLevel));
      }
      
      private function unload(filesToUnload:Array, groupsToUnload:Array):void
      {
         // cleanup extra loaded stuff
         for each (var extraEntity:IEntity in _loadedEntities)
         {
            extraEntity.eventDispatcher.removeEventListener("EntityDestroyed", onEntityDestroyed);
            extraEntity.destroy();
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
            {
               if (groupEntity) 
               {
                   groupEntity.destroy();
               }
            }
            
            //Destroy all created groups, except the root group:
			if(groupName != PBE.rootGroup.name)
			{
				var actualGroup:PBGroup = PBE.nameManager.lookup(groupName) as PBGroup;
            
				if(actualGroup != null)
				{
					actualGroup.destroy();
				}
            }
			
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
            
            PBE.templateManager.unloadFile(filename);
            _loadedFiles[filename] = null;
            delete _loadedFiles[filename];
         }
      }
      
      private function getLoadLists(previousList:Array, nextList:Array, loadList:Array, unloadList:Array):void
      {
         if (nextList)
         {
            for each (var loadName:String in nextList)
            {
               // if it's in the previous list, don't need to load it
               if (previousList && previousList.indexOf(loadName) != -1)
                  continue;
            
               loadList.push(loadName);
            }
         }
         
         if (previousList)
         {
            for each (var unloadName:String in previousList)
            {
               // if it's in the next list, don't need to unload it
               if (nextList && nextList.indexOf(unloadName) != -1)
                  continue;
            
               unloadList.push(unloadName);
            }
         }
      }
      
      private function onEntityDestroyed(event:Event):void
      {
      }
      
      /**
       * Register a file with a level number. The same file can be registered with several levels.
       * 
       * @param index The level to register with
       * @param filename The file to register
       */
      public function addFileReference(index:int, filename:String):void
      {
         if (_isLevelLoaded && (_currentLevel == index))
         {
            Logger.error(this, "AddFileReference", "Cannot add level information to a level that is loaded.");
            return;
         }
         
         var levelDescription:LevelDescription = getLevelDescription(index);
         levelDescription.files.push(filename);
      }
      
      /**
       * Remove a file from a level number.
       * 
       * @param index The level to remove from
       * @param filename The file to remove
       */
      public function removeFileReference(index:int, filename:String):void
      {
         if (!hasLevelData(index))
         {
            Logger.error(this, "RemoveFileReference", "No level data exists for level " + index + ".");
            return;
         }
         
         var levelIndex:int = levelDescription.files.indexOf(filename);
         if (levelIndex == -1)
         {
            Logger.error(this, "RemoveFileReference", "The file " + filename + " was not found in the level " + index + ".");
            return;
         }
         
         var levelDescription:LevelDescription = getLevelDescription(index);
         levelDescription.files.splice(levelIndex, 1);
      }
      
      /**
       * Register a group with a level number. The same group can be registered with several levels.
       * 
       * @param index The level to register with
       * @param name The name of the group to register
       */
      public function addGroupReference(index:int, name:String):void
      {
         if (_isLevelLoaded && (_currentLevel == index))
         {
            Logger.error(this, "AddGroupReference", "Cannot add level information to a level that is loaded.");
            return;
         }
         
         var levelDescription:LevelDescription = getLevelDescription(index);
         levelDescription.groups.push(name);
      }
      
      /**
       * Remove a group from a level number.
       * 
       * @param index The level to remove from
       * @param name The group to remove
       */
      public function removeGroupReference(index:int, name:String):void
      {
         if (!hasLevelData(index))
         {
            Logger.error(this, "RemoveGroupReference", "No level data exists for level " + index + ".");
            return;
         }
         
         var groupIndex:int = levelDescription.groups.indexOf(name);
         if (groupIndex == -1)
         {
            Logger.error(this, "RemoveFileReference", "The group " + name + " was not found in the level " + index + ".");
            return;
         }
         
         var levelDescription:LevelDescription = getLevelDescription(index);
         levelDescription.groups.splice(groupIndex, 1);
      }
      
      /**
       * Removes the level with the specified index.
       * 
       * @param index The index of the level to remove.
       */
      public function removeLevel(index:int):void
      {
         if (!hasLevelData(index))
         {
            Logger.error(this, "RemoveLevel", "No level data exists for level " + index + ".");
            return;
         }
         
         _levelDescriptions[index] = null;
         delete _levelDescriptions[index];
      }
      
      public function getLevelDescription(index:int):LevelDescription
      {
         var levelDescription:LevelDescription = _levelDescriptions[index];
         if (!levelDescription)
         {
            levelDescription = new LevelDescription();
            levelDescription.index = index;
            _levelDescriptions[index] = levelDescription;
         }
         
         return levelDescription;
      }
      
      private function hasLevelData(index:int):Boolean
      {
         return _levelDescriptions[index];
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
   public var name:String = "";
   public var index:int = 0;
   
   public var files:Array = new Array();
   public var groups:Array = new Array();
}