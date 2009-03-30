package PBLabs.Animation
{
   import PBLabs.Engine.Debug.Logger;
   
   import flash.events.EventDispatcher;
   
   public class Animator extends EventDispatcher
   {
      public function get StartValue():*
      {
         return _start;
      }
      
      public function set StartValue(value:*):void
      {
         _start = value;
      }
      
      public function get TargetValue():*
      {
         return _target;
      }
      
      public function set TargetValue(value:*):void
      {
         _target = value;
      }
      
      public function get CurrentValue():*
      {
         return _current;
      }
      
      public function get AnimationType():AnimatorType
      {
         if (IsAnimating)
            return _type;
         
         return _previousType;
      }
      
      public function set AnimationType(value:AnimatorType):void
      {
         if (IsAnimating)
            _type = value;
         else
            _previousType = value;
      }
      
      public function get TotalRepeatCount():int
      {
         return _totalRepeatCount;
      }
      
      public function get RepeatCount():int
      {
         if (IsAnimating)
            return _repeatCount;
         
         return _totalRepeatCount;
      }
      
      public function set RepeatCount(value:int):void
      {
         if (IsAnimating)
            _repeatCount = value;
         else
            _totalRepeatCount = value;
      }
      
      public function get Duration():Number
      {
         return _duration;
      }
      
      public function set Duration(value:Number):void
      {
         _duration = value;
      }
      
      public function get Elapsed():Number
      {
         return _elapsedTime;
      }
      
      public function get IsAnimating():Boolean
      {
         return _type != AnimatorType.NoAnimation;
      }
      
      public function Start(startValue:*, targetValue:*, duration:Number, type:AnimatorType, repeatCount:int = 0):void
      {
         if (IsAnimating)
            Stop();
         
         _start = startValue;
         _target = targetValue;
         _duration = duration;
         _previousType = type;
         _totalRepeatCount = repeatCount;
         
         Reset();
         Play();
      }
      
      public function Play():void
      {
         if (IsAnimating)
            return;
         
         _type = _previousType;
         _previousType = AnimatorType.NoAnimation;
         
         if (_elapsedTime == 0.0)
            dispatchEvent(new AnimationEvent(AnimationEvent.ANIMATION_STARTED_EVENT, this));
         else
            dispatchEvent(new AnimationEvent(AnimationEvent.ANIMATION_RESUMED_EVENT, this));
      }
      
      public function Stop():void
      {
         if (!IsAnimating)
            return;
         
         _previousType = _type;
         _type = AnimatorType.NoAnimation;
         
         dispatchEvent(new AnimationEvent(AnimationEvent.ANIMATION_STOPPED_EVENT, this));
      }
      
      public function Finish():void
      {
         if (!IsAnimating)
            return;
         
         if ((_type == AnimatorType.PingPongAnimation) && (_repeatCount & 1))
            _current = _start;
         else
            _current = _target;
         
         _previousType = _type;
         _type = AnimatorType.NoAnimation;
         
         dispatchEvent(new AnimationEvent(AnimationEvent.ANIMATION_FINISHED_EVENT, this));
      }
      
      public function Reset():void
      {
         if (IsAnimating)
            Stop();
         
         _current = _start;
         _elapsedTime = 0.0;
         _repeatCount = _totalRepeatCount;
      }
      
      public function Reverse():void
      {
         var swap:* = _target;
         _target = _start;
         _start = swap;
      }
      
      public function Animate(elapsed:Number):void
      {
         if (_type == AnimatorType.NoAnimation)
            return;
      
         _elapsedTime += elapsed;
         if (_elapsedTime > _duration)
         {
            if ((_type == AnimatorType.PlayAnimationOnce) || (_repeatCount == 0))
            {
               Finish();
               return;
            }
         
            if (_type == AnimatorType.PingPongAnimation)
               Reverse();
         
            // set the elapsed time to the leftover time
            _elapsedTime = Math.abs(_duration - _elapsedTime);
         
            // one less repeat
            if (_repeatCount > 0)
               _repeatCount--;
            
            dispatchEvent(new AnimationEvent(AnimationEvent.ANIMATION_REPEATED_EVENT, this));
         }
      
         _current = _Interpolate(_start, _target, _elapsedTime / _duration);
      }
      
      protected function _Interpolate(start:*, end:*, time:Number):*
      {
         // gotta do things a little funny or else these things will be treated as strings
         if ((end - start) < 0)
            return start - ((start - end) * time);
         
         return start + ((end - start) * time);
      }
      
      private var _type:AnimatorType = AnimatorType.NoAnimation;
      private var _previousType:AnimatorType = AnimatorType.NoAnimation;
      
      private var _repeatCount:int = 0;
      private var _totalRepeatCount:int = 0;
      
      private var _start:*;
      private var _target:*;
      private var _current:*;
      
      private var _elapsedTime:Number = 0.0;
      private var _duration:Number;
   }
}