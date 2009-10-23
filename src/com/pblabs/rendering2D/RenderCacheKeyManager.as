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