package com.pblabs.tweaker
{
   import com.pblabs.engine.entity.*;
   
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
