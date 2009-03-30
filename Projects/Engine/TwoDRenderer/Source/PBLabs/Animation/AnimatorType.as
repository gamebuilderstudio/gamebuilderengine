package PBLabs.Animation
{
   import PBLabs.Engine.Serialization.*;
   import PBLabs.Engine.Debug.Logger;
   import PBLabs.Engine.Serialization.Enumerable;
   
   import flash.utils.Dictionary;
   
   public class AnimatorType extends Enumerable
   {
      public static const NoAnimation:AnimatorType = new AnimatorType();
      public static const PlayAnimationOnce:AnimatorType = new AnimatorType();
      public static const LoopAnimation:AnimatorType = new AnimatorType();
      public static const PingPongAnimation:AnimatorType = new AnimatorType();
      
      private static var _typeMap:Dictionary = null;
      
      public override function get TypeMap():Dictionary
      {
         if (_typeMap == null)
         {
            _typeMap = new Dictionary();
            _typeMap["NoAnimation"] = NoAnimation;
            _typeMap["PlayAnimationOnce"] = PlayAnimationOnce;
            _typeMap["LoopAnimation"] = LoopAnimation;
            _typeMap["PingPongAnimation"] = PingPongAnimation;
         }
         
         return _typeMap;
      }
      
      public override function get DefaultType():Enumerable
      {
         return NoAnimation;
      }
   }
}