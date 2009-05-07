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
    * The GroupReference class is meant to be used as an MXML tag to associate groups
    * with level numbers in the LevelManager.
    * 
    * @see PBLabs.Engine.Core.LevelManager
    */
   public class GroupReference implements IMXMLObject
   {
      [Bindable]
      /**
       * The name of the group to instantiate with this reference.
       */
      public var name:String = "";
      
      [Bindable]
      /**
       * The levels at which the group will be instantiated.
       */
      public var levels:Array = new Array();
      
      [Bindable]
      /**
       * The level at which the group will be instantiated. If levels is set, this is ignored.
       */
      public var level:int = -1;
      
      [Bindable]
      /**
       * Setting this to true will keep the level manager from unloading this group
       * when advancing to the next level.
       */
      public var persist:Boolean = false;
      
      /**
       * @inheritDoc
       */
      public function initialized(document:Object, id:String):void
      {
         if (levels == null || levels.length == 0)
         {
            LevelManager.Instance.AddGroupReference(name, level, persist);
         }
         else
         {
            for each (var l:int in levels)
               LevelManager.Instance.AddGroupReference(name, l, persist);
         }
      }
   }
}