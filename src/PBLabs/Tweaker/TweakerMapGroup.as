package PBLabs.Tweaker
{
   import PBLabs.Engine.Entity.*;
   
   /**
    */
   public class TweakerMapGroup
   {
      [TypeHint(type="PBLabs.Tweaker.TweakerMapEntry")]
      public var Entries:Array = new Array();

      [TypeHint(type="PBLabs.Tweaker.TweakerMapEntry")]
      public var Offsets:Array = new Array();
   }
}
