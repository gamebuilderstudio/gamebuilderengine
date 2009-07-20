/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Animation
{
   import PBLabs.Engine.Debug.Logger;
   
   import flash.events.EventDispatcher;
   
   /**
    * @eventType PBLabs.Animation.AnimationEvent.ANIMATION_STARTED_EVENT
    */
   [Event(name="ANIMATION_STARTED_EVENT", type="PBLabs.Animation.AnimationEvent")]
   
   /**
    * @eventType PBLabs.Animation.AnimationEvent.ANIMATION_RESUMED_EVENT
    */
   [Event(name="ANIMATION_RESUMED_EVENT", type="PBLabs.Animation.AnimationEvent")]
   
   /**
    * @eventType PBLabs.Animation.AnimationEvent.ANIMATION_REPEATED_EVENT
    */
   [Event(name="ANIMATION_REPEATED_EVENT", type="PBLabs.Animation.AnimationEvent")]
   
   /**
    * @eventType PBLabs.Animation.AnimationEvent.ANIMATION_STOPPED_EVENT
    */
   [Event(name="ANIMATION_STOPPED_EVENT", type="PBLabs.Animation.AnimationEvent")]
   
   /**
    * @eventType PBLabs.Animation.AnimationEvent.ANIMATION_FINISHED_EVENT
    */
   [Event(name="ANIMATION_FINISHED_EVENT", type="PBLabs.Animation.AnimationEvent")]
   
   /**
    * Class for animating between a start value and end value.
    * 
    * <p>To animate more complex types, subclass this and implement the interpolate
    * method.</p>
    */
   public class Animator extends EventDispatcher
   {
      /**
       * The value the animation should start at.
       */
      public function get StartValue():*
      {
         return _start;
      }
      
      /**
       * @private
       */
      public function set StartValue(value:*):void
      {
         _start = value;
      }
      
      /**
       * The value to animate to.
       */
      public function get TargetValue():*
      {
         return _target;
      }
      
      /**
       * @private
       */
      public function set TargetValue(value:*):void
      {
         _target = value;
      }
      
      /**
       * The current value of the animation.
       */
      public function get CurrentValue():*
      {
         return _current;
      }
      
      /**
       * The type of playback to use for the animation.
       */
      public function get AnimationType():AnimatorType
      {
         if (IsAnimating)
            return _type;
         
         return _previousType;
      }
      
      /**
       * @private
       */
      public function set AnimationType(value:AnimatorType):void
      {
         if (IsAnimating)
            _type = value;
         else
            _previousType = value;
      }
      
      /**
       * The total number of times to repeat the animation.
       */
      public function get TotalRepeatCount():int
      {
         return _totalRepeatCount;
      }
      
      /**
       * The remaining number of times the animation will be repeated.
       */
      public function get RepeatCount():int
      {
         if (IsAnimating)
            return _repeatCount;
         
         return _totalRepeatCount;
      }
      
      /**
       * @private
       */
      public function set RepeatCount(value:int):void
      {
         if (IsAnimating)
            _repeatCount = value;
         else
            _totalRepeatCount = value;
      }
      
      /**
       * The time it should take to animate from the start value to the target value.
       */
      public function get Duration():Number
      {
         return _duration;
      }
      
      /**
       * @private
       */
      public function set Duration(value:Number):void
      {
         _duration = value;
      }
      
      /**
       * The amount of time that has passed since the animation started.
       */
      public function get Elapsed():Number
      {
         return _elapsedTime;
      }
      
      /**
       * Whether or not the animation is currently playing.
       */
      public function get IsAnimating():Boolean
      {
         return _type != AnimatorType.NoAnimation;
      }
      
      /**
       * Starts the animation. This is simply a shorthand way to specify all the necessary parameters
       * for playback. Play can be called instead if the properties are already set.
       */
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
      
      /**
       * Starts playback.
       */
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
      
      /**
       * Stops playback. It can be resumed by calling Play.
       */
      public function Stop():void
      {
         if (!IsAnimating)
            return;
         
         _previousType = _type;
         _type = AnimatorType.NoAnimation;
         
         dispatchEvent(new AnimationEvent(AnimationEvent.ANIMATION_STOPPED_EVENT, this));
      }
      
      /**
       * Set the current value to the target value instantly.
       */
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
      
      /**
       * Resets the animation to all the values it had before it started playing.
       */
      public function Reset():void
      {
         if (IsAnimating)
            Stop();
         
         _current = _start;
         _elapsedTime = 0.0;
         _repeatCount = _totalRepeatCount;
      }
      
      /**
       * Reverses the animation, effectively setting the start value to the target value and
       * the target value to the start value.
       */
      public function Reverse():void
      {
         var swap:* = _target;
         _target = _start;
         _start = swap;
      }
      
      /**
       * This should be called every frame to perform the animation.
       * 
       * @param elapsed The amount of time that has elapsed since the last call to this.
       */
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
      
      /**
       * Performs the actual animation. This can be overridden by subclasses to interpolate
       * more complex types. This default implementation will only work for values that can
       * use the +, -, and * operators.
       * 
       * @param start The value to interpolate from.
       * @param end The value to interpolate to.
       * @param time The interpolation factor. A value of 0 will return the start value, a
       * value of 1 will return the end value. A value of 0.5 should return the value half
       * way between start and end.
       * 
       * @return The interpolated value.
       */
      protected function _Interpolate(start:*, end:*, time:Number):*
      {
         // Have to be careful to convert to numbers.
         var startN:Number = Number(start);
         var endN:Number = Number(end);
         
         // Do the interpolation.
         if ((endN - startN) < 0)
            return startN - ((startN - endN) * time);
         
         return startN + ((endN - startN) * time);
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