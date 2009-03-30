package PBLabs.Animation
{
   import PBLabs.Engine.Components.AnimatedComponent;
   import PBLabs.Engine.Entity.PropertyReference;
   import flash.utils.Dictionary;
   
   public class AnimatorComponent extends AnimatedComponent
   {
      public var Reference:PropertyReference = null;
      
      public var Animations:Dictionary = null;
      
      public var DefaultAnimation:String = "Idle";
      
      public var AutoPlay:Boolean = true;
      
      public override function OnFrame(elapsed:Number):void
      {
         _currentAnimation.Animate(elapsed);
         Owner.SetProperty(Reference, _currentAnimation.CurrentValue);
      }
      
      public function Play(animation:String, startValue:*):void
      {
         _currentAnimation = Animations[animation];
         _currentAnimation.StartValue = startValue;
         _currentAnimation.Reset();
         _currentAnimation.Play();
      }
      
      protected override function _OnReset():void
      {
         if (!AutoPlay || (_currentAnimation != null))
            return;
         
         var value:* = Owner.GetProperty(Reference);
         if (value != null)
            Play(DefaultAnimation, value);
      }
      
      private var _currentAnimation:Animator = null;
   }
}