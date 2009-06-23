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
   import PBLabs.Engine.Resource.*;
   import PBLabs.Rendering2D.ImageResource;
   
   import flash.utils.ByteArray;
   
   public class Resources
   {
      [Embed(source="../Assets/Levels/level.pbelevel", mimeType='application/octet-stream')]
      private var _level:Class;
      
      [Embed(source="../Assets/Images/mannequin.png", mimeType='application/octet-stream')]
      private var _mannequin:Class;
      
      [Embed(source="../Assets/Images/platform.png", mimeType='application/octet-stream')]
      private var _platform:Class;
      
      [Embed(source="../Assets/Sounds/testSound.mp3")]
      private var _testSound:Class;
      
      public function Resources()
      {
         ResourceManager.Instance.RegisterEmbeddedResource("../Assets/Levels/level.pbelevel", XMLResource, new _level() as ByteArray);
         ResourceManager.Instance.RegisterEmbeddedResource("../Assets/Images/mannequin.png", ImageResource, new _mannequin() as ByteArray);
         ResourceManager.Instance.RegisterEmbeddedResource("../Assets/Images/platform.png", ImageResource, new _platform() as ByteArray);
         ResourceManager.Instance.RegisterEmbeddedResource("../Assets/Sounds/testSound.mp3", MP3Resource, new _testSound());
      }
   }
}