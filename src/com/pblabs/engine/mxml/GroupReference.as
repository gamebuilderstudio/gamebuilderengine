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
    * The GroupReference class is meant to be used as an MXML tag to associate groups
    * with level numbers in the LevelManager.
    * 
    * @see com.pblabs.engine.core.LevelManager
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
      
      /**
       * @inheritDoc
       */
      public function initialized(document:Object, id:String):void
      {
         if (!levels || levels.length == 0)
         {
            LevelManager.instance.addGroupReference(level, name);
         }
         else
         {
            for each (var l:int in levels)
               LevelManager.instance.addGroupReference(l, name);
         }
      }
   }
}