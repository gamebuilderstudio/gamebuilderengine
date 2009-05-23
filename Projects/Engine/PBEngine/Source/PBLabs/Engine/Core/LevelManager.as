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
   
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import flash.utils.setTimeout;
   
   /**
    * @eventType PBLabs.Engine.Core.LevelEvent.LOADED_EVENT
    */
   [Event(name="LOADED_EVENT", type="PBLabs.Engine.Core.LevelEvent")]
   
   /**
    * The LevelManager allows level files and groups to be added to a specific level so they
    * can be automatically managed when that level is loaded or unloaded.
    * 
    * @see PBLabs.Engine.MXML.LevelFileReference
    * @see PBLabs.Engine.MXML.GroupReference
    * @see PBLabs.Engine.MXML.AutoLoadLevelReference
    */
   public class LevelManager extends EventDispatcher
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
         return _currentLevel;
      }
      
      /**
       * Starts the LevelManager by loading all content marked for auto load. This is
       * automatically called when initializing level references from an MXML file.
       */
      public function Start():void
      {
         _autoLoading = true;
         _LoadNextAutoLevel();
      }
      
      /**
       * Marks a level to be loaded automatically. Level 0 is auto loaded by default.
       * 
       * @param level The level to auto load.
       * 
       * @see AutoLoadLevelReference
       */
      public function AddAutoLoadLevel(level:int):void
      {
         _autoLoadLevels.push(level);
      }
      
      /**
       * Registers a level file with a specific level number.
       * 
       * @param filename The filename containing the level contents to load with the specified
       * level.
       * @param level The level to register this file with.
       * @param persist Set this to true to keep the file loaded beyond when the level is
       * unloaded.
       */
      public function AddLevelFileReference(filename:String, level:int, persist:Boolean = false):void
      {
         if (_levelInformation[level] == null)
            _levelInformation[level] = new Array();
         
         var reference:ReferenceObject = new ReferenceObject();
         reference.Name = filename;
         reference.Persist = persist;
         _levelInformation[level].push(reference);
      }
      
      /**
       * Registers a group with a specific level number.
       * 
       * @param name The name of the group to instantiate when the specified level is loaded.
       * @param level The level to register this group with.
       * @param persist Set this to true to keep the group loaded beyond when the level is
       * unloaded.
       */
      public function AddGroupReference(name:String, level:int, persist:Boolean = false):void
      {
         if (_groupInformation[level] == null)
            _groupInformation[level] = new Array();
         
         var reference:ReferenceObject = new ReferenceObject();
         reference.Name = name;
         reference.Persist = persist;
         _groupInformation[level].push(reference);
      }
      
      /**
       * Unloads the currently loaded level and loads the next level.
       * 
       * <p>The level data is loaded asynchronously. The LOADED_EVENT is dispatched when
       * the data has finished loading.</p>
       */
      public function LoadNextLevel():void
      {
         LoadLevel(_currentLevel + 1);
      }
      
      /**
       * Unloads the currently loaded level and loads the specified level.
       * 
       * <p>The level data is loaded asynchronously. The LOADED_EVENT is dispatched when
       * the data has finished loading.</p>
       * 
       * @param level The level to load.
       */
      public function LoadLevel(level:int):void
      {
         if (_loadingLevel)
         {
            Logger.PrintWarning(this, "LoadLevel", "The LevelManager is already in the process of loading a level.");
            return;
         }
         
         _loadingLevel = true;
         UnloadCurrentLevel();
         _currentLevel = level;
         
         if (_levelInformation[level] == null)
         {
            if (_groupInformation[level] != null)
            {
               // We have groups anyway - so just force them.
               _OnLevelInformationLoaded();
               return;
            }
            
            _loadingLevel = false;
            
            if (_autoLoading)
               _LoadNextAutoLevel();
            else
               Logger.PrintWarning(this, "LoadLevel", "No level information has been added for level " + level + ".");
            
            return;
         }
         
         _loadedCount = 0;
         _levelFileCount = _levelInformation[level].length;
         TemplateManager.Instance.addEventListener(TemplateManager.LOADED_EVENT, _OnFileLoaded);
         TemplateManager.Instance.addEventListener(TemplateManager.FAILED_EVENT, _OnFileLoaded);
         for each (var reference:ReferenceObject in _levelInformation[level])
            TemplateManager.Instance.LoadFile(reference.Name);
      }
      
      /**
       * Unloads the currently loaded level.
       */
      public function UnloadCurrentLevel():void
      {
         UnloadLevel(_currentLevel);
      }
      
      /**
       * Unloads the specified level.
       * 
       * @param level The level to unload.
       * @param evenPersistent Set this to true to unload even data that was marked as persistent.
       */
      public function UnloadLevel(level:int, evenPersistent:Boolean = false):void
      {
         for each (var groupReference:ReferenceObject in _groupInformation[_currentLevel])
         {
            if (groupReference.Persist && !evenPersistent)
               continue;
            
            for each (var entity:IEntity in groupReference.LoadedStuff)
            {
               if(entity)
                  entity.Destroy();
            }
            
            groupReference.LoadedStuff.splice(0, groupReference.LoadedStuff.length);
         }
         
         for each (var levelReference:ReferenceObject in _levelInformation[_currentLevel])
         {
            if (levelReference.Persist && !evenPersistent)
               continue;
            
            TemplateManager.Instance.UnloadFile(levelReference.Name);
         }
      }
      
      private function _LoadNextAutoLevel():void
      {
         if (_autoLoadLevels.length == 0)
         {
            _autoLoading = false;
            return;
         }
         
         var level:int = _autoLoadLevels.shift();
         LoadLevel(level);
      }
      
      private function _OnFileLoaded(event:Event):void
      {
         _loadedCount++;
         if (_loadedCount == _levelFileCount)
         {
            TemplateManager.Instance.addEventListener(TemplateManager.LOADED_EVENT, _OnFileLoaded);
            TemplateManager.Instance.addEventListener(TemplateManager.FAILED_EVENT, _OnFileLoaded);
            _OnLevelInformationLoaded();
         }
      }
      
      private function _OnLevelInformationLoaded():void
      {
         for (var i:int = 0; i < _groupInformation[_currentLevel].length; i++)
         {
            var reference:ReferenceObject = _groupInformation[_currentLevel][i];
            var newStuff:Array = reference.LoadedStuff.concat(TemplateManager.Instance.InstantiateGroup(reference.Name));
            reference.LoadedStuff = newStuff;
         }
         
         _loadingLevel = false;
         dispatchEvent(new LevelEvent(LevelEvent.LOADED_EVENT, _currentLevel));
         
         if (_autoLoading)
            _LoadNextAutoLevel();
      }
      
      private var _currentLevel:int = 0;
      private var _levelInformation:Dictionary = new Dictionary();
      private var _groupInformation:Dictionary = new Dictionary();
      
      private var _autoLoading:Boolean = false;
      private var _autoLoadLevels:Array = [ 0 ];
      
      private var _loadingLevel:Boolean = false;
      private var _levelFileCount:int = -1;
      private var _loadedCount:int = 0;
   }
}

class ReferenceObject
{
   public var Name:String;
   public var Persist:Boolean;
   public var LoadedStuff:Array = new Array();
}