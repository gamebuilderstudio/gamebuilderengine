/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Engine.MXML
{
   import PBLabs.Engine.Core.LevelManager;
   
   import mx.core.IMXMLObject;
   
   /**
    * The AutoLoadLevelReference class is meant to be used as an MXML tag to tell
    * the LevelManager which levels should be automatically loaded.
    * 
    * @see PBLabs.Engine.Core.LevelManager
    */
   public class AutoLoadLevelReference implements IMXMLObject
   {
      [Bindable]
      /**
       * The levels to load automatically.
       */
      public var levels:Array = null;
      
      [Bindable]
      /**
       * The level to load automatically. If levels is set, this is ignored.
       */
      public var level:int = -1;
      
      /**
       * @inheritDoc
       */
      public function initialized(document:Object, id:String):void
      {
         if (levels == null)
         {
            LevelManager.Instance.AddAutoLoadLevel(level);
         }
         else
         {
            for each (var l:int in levels)
               LevelManager.Instance.AddAutoLoadLevel(l);
         }
      }
   }
}