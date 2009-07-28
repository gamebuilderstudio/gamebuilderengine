/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.mxml
{
   import com.pblabs.engine.core.LevelManager;
   
   import mx.core.IMXMLObject;
   
   /**
    * The LevelFileReference class is meant to be used as an MXML tag to associate level
    * files with level numbers in the LevelManager.
    * 
    * @see com.pblabs.engine.core.LevelManager
    */
   public class LevelFileReference implements IMXMLObject
   {
      [Bindable]
      /**
       * The filename of the level file to load with this reference.
       */
      public var filename:String = "";
      
      [Bindable]
      /**
       * The levels at which the level file will be loaded.
       */
      public var levels:Array = new Array();
      
      [Bindable]
      /**
       * The level at which the level file will be loaded. If levels is set, this is ignored.
       */
      public var level:int = -1;
      
      /**
       * @inheritDoc
       */
      public function initialized(document:Object, id:String):void
      {
         if (!levels || levels.length == 0)
         {
            LevelManager.instance.addFileReference(level, filename);
         }
         else
         {
            for each (var l:int in levels)
               LevelManager.instance.addFileReference(l, filename);
         }
      }
   }
}