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
   import com.pblabs.engine.resource.*;
   import com.pblabs.rendering2D.ImageResource;
   
   import flash.utils.ByteArray;
   
   public class Resources extends ResourceBundle
   {
      [Embed(source="../Assets/Levels/common.pbelevel", mimeType='application/octet-stream')]
      private var _levelCommon:Class;
      [Embed(source="../Assets/Levels/level1.pbelevel", mimeType='application/octet-stream')]
      private var _level1:Class;
      [Embed(source="../Assets/Levels/level2.pbelevel", mimeType='application/octet-stream')]
      private var _level2:Class;
      [Embed(source="../Assets/Levels/level3.pbelevel", mimeType='application/octet-stream')]
      private var _level3:Class;
      [Embed(source="../Assets/Levels/spriteSheets.pbelevel", mimeType='application/octet-stream')]
      private var _levelSprites:Class;
      [Embed(source="../Assets/Levels/templates.pbelevel", mimeType='application/octet-stream')]
      private var _levelTemplates:Class;

      [Embed(source="../Assets/Images/mannequin.png", mimeType='application/octet-stream')]
      private var _mannequin:Class;
      [Embed(source="../Assets/Images/platform.png", mimeType='application/octet-stream')]
      private var _platform:Class;
      
      [Embed(source="../Assets/Sounds/testSound.mp3")]
      private var _testSound:Class;
   }
}