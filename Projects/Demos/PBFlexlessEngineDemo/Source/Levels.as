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
   import PBLabs.Engine.Core.LevelManager;
   
   public class Levels
   {
      public function Levels()
      {
         LevelManager.Instance.AddLevelFileReference("../Assets/Levels/level.pbelevel", 0);
         LevelManager.Instance.AddGroupReference("Everything", 0);
         LevelManager.Instance.Start();
      }
   }
}