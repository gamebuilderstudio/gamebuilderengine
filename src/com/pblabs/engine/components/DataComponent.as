/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.engine.components
{
   import com.pblabs.engine.entity.EntityComponent;
   
   /**
    * Container for arbitrary data. As it is dynamic, you can set whatever
    * fields you want. Useful for storing general purpose data.
    */
   
   [EditorData(editAs="flash.utils.Dictionary")]
   public dynamic class DataComponent extends EntityComponent
   {
   }
}