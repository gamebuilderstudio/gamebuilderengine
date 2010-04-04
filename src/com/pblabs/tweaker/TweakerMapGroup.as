/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.tweaker
{
   /**
    */
   public class TweakerMapGroup
   {
      [TypeHint(type="com.pblabs.tweaker.TweakerMapEntry")]
      public var entries:Array = new Array();

      [TypeHint(type="com.pblabs.tweaker.TweakerMapEntry")]
      public var offsets:Array = new Array();
   }
}
