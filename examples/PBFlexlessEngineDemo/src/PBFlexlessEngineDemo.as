/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/

package
{
   import com.pblabs.engine.PBE;
   import com.pblabs.engine.core.LevelManager;
   
   import flash.display.Sprite;
   import flash.utils.*;
   
   [SWF(width="800", height="600", frameRate="60")]
   public class PBFlexlessEngineDemo extends Sprite
   {
      public function PBFlexlessEngineDemo()
      {
         _resources = new Resources();
         _references = new References();
         
         PBE.startup(this);
         
         LevelManager.instance.load("../assets/levelDescriptions.xml");
         
         // Load first level momentarily.
         setTimeout( function():void 
         {
            trace("Loading level 1."); 
            LevelManager.instance.loadLevel(1); 
         }, 100);
      }
      
      private var _resources:Resources;
      private var _references:References;
   }
}
