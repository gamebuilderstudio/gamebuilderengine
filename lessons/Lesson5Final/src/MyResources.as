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
   
   public class MyResources extends ResourceBundle
   {
      [Embed(source="../assets/bg.jpg")]
      public var resBg:Class;
      
      [Embed(source="../assets/fanship.png")]
      public var resShip:Class;
   }
}
