/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.rendering2D
{
   [EditorData(ignore="true")]
   
   /**
    * Helper class to manage RenderCacheKey values; basically just a global int
    * that we can increment to get new values to trigger cache invalidation.
    * 
    * @see IDrawManager2D
    * 
    */ 
    public final class RenderCacheKeyManager
    {
       public static var Token:int = 0;
    }
}