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
	import com.pblabs.engine.entity.PropertyReference;
   
   /** 
    * Map a cell (specified in standard spreadsheet notation, ie E4) to
    * a PropertyReference.
    * <p>
    * Most of the time you will want to set a value in a template, which can
    * be done using a PropertyReference in the form of 
    * !TemplateName.ComponentName.PropertyName.</p>
    */
   public class TweakerMapEntry
   {
      public var cell:String;
      public var property:PropertyReference;
      
      public function toString():String
      {
         return "[TweakerMapEntry " + cell + " = " + property.property + "]";
      }
   }
}