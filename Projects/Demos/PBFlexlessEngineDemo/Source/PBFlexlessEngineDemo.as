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
   import PBLabs.Engine.Core.Global;
   
   import flash.display.Sprite;
   
   [SWF(width="800", height="600", frameRate="60")]
   public class PBFlexlessEngineDemo extends Sprite
   {
      public function PBFlexlessEngineDemo()
      {
         _resources = new Resources();
         _components = new Components();
         _levels = new Levels();
         
         Global.Startup(this);
      }
      
      private var _resources:Resources;
      private var _components:Components;
      private var _levels:Levels;
   }
}
