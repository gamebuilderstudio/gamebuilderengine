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
   import com.pblabs.rendering2D.*;
   
   public class MyResources extends ResourceBundle
   {
      [Embed(source="bg.jpg", mimeType='application/octet-stream')]
      public var resBg:Class;
      
      [Embed(source="fanship.png", mimeType='application/octet-stream')]
      public var resShip:Class;
   }
}
