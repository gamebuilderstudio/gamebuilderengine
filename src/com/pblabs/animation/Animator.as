/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.animation
{
    import com.pblabs.engine.debug.Logger;
    import flash.events.EventDispatcher;
    /**
     * @eventType com.pblabs.animation.AnimationEvent.ANIMATION_STARTED_EVENT
     */
    [Event(name="ANIMATION_STARTED_EVENT",type="com.pblabs.animation.AnimationEvent")]
    /**
     * @eventType com.pblabs.animation.AnimationEvent.ANIMATION_RESUMED_EVENT
     */
    [Event(name="ANIMATION_RESUMED_EVENT",type="com.pblabs.animation.AnimationEvent")]
    /**
     * @eventType com.pblabs.animation.AnimationEvent.ANIMATION_REPEATED_EVENT
     */
    [Event(name="ANIMATION_REPEATED_EVENT",type="com.pblabs.animation.AnimationEvent")]
    /**
     * @eventType com.pblabs.animation.AnimationEvent.ANIMATION_STOPPED_EVENT
     */
    [Event(name="ANIMATION_STOPPED_EVENT",type="com.pblabs.animation.AnimationEvent")]
    /**
     * @eventType com.pblabs.animation.AnimationEvent.ANIMATION_FINISHED_EVENT
     */
    [Event(name="ANIMATION_FINISHED_EVENT",type="com.pblabs.animation.AnimationEvent")]
    
	/**
     * Class for animating between a start value and end value.
     *
     * <p>To animate more complex types, subclass this and implement the interpolate
     * method.</p>
     */
    public class Animator extends EventDispatcher
    {
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------

        private var _previousType:AnimatorType = AnimatorType.NO_ANIMATION;
		
		//--------------------------------------
		//  repeatCount
		//--------------------------------------
        private var _repeatCount:int = 0;
		
		/**
		 * The remaining number of times the animation will be repeated.
		 */
		public function get repeatCount():int
		{
			if (isAnimating)
				return _repeatCount;
			
			return _totalRepeatCount;
		}
		
		/**
		 * @private
		 */
		public function set repeatCount(value:int):void
		{
			if (isAnimating)
				_repeatCount = value;
			else
				_totalRepeatCount = value;
		}
		
		//--------------------------------------
		//  currentValue
		//--------------------------------------
        private var _current:*;
		
		/**
		 * The current value of the animation.
		 */
		public function get currentValue():*
		{
			return _current;
		}
		
		//--------------------------------------
		//  elapsed
		//--------------------------------------
        private var _elapsedTime:Number = 0.0;
		
		/**
		 * The amount of time that has passed since the animation started.
		 */
		public function get elapsed():Number
		{
			return _elapsedTime;
		}
		
		//--------------------------------------
		//  duration
		//--------------------------------------
        private var _duration:Number;
		
		/**
		 * The time it should take to animate from the start value to the target value.
		 */
		public function get duration():Number
		{
			return _duration;
		}
		
		/**
		 * @private
		 */
		public function set duration(value:Number):void
		{
			_duration = value;
		}

		
		//--------------------------------------
		//  animationType
		//--------------------------------------
		private var _type:AnimatorType = AnimatorType.NO_ANIMATION;
		
		/**
		 * The type of playback to use for the animation.
		 */
		public function get animationType():AnimatorType
		{
			if (isAnimating)
				return _type;
			
			return _previousType;
		}
		
		/**
		 * @private
		 */
		public function set animationType(value:AnimatorType):void
		{
			if (isAnimating)
				_type = value;
			else
				_previousType = value;
		}

		//--------------------------------------
		//  isAnimating
		//--------------------------------------
		
        /**
         * Whether or not the animation is currently playing.
         */
        public function get isAnimating():Boolean
        {
            return _type != AnimatorType.NO_ANIMATION;
        }

		//--------------------------------------
		//  startValue
		//--------------------------------------
		private var _start:*;
		
        /**
         * The value the animation should start at.
         */
        
        [TypeHint(type="dynamic")]
        public function get startValue():*
        {
            return _start;
        }

        /**
         * @private
         */
        public function set startValue(value:*):void
        {
            _start = value;
        }

		//--------------------------------------
		//  targetValue
		//--------------------------------------
		private var _target:*;
		
        /**
         * The value to animate to.
         */
        [TypeHint(type="dynamic")]
        public function get targetValue():*
        {
            return _target;
        }

        /**
         * @private
         */
        public function set targetValue(value:*):void
        {
            _target = value;
        }
		
		//--------------------------------------
		//  totalRepeatCount
		//--------------------------------------
		private var _totalRepeatCount:int = 0;
		
        /**
         * The total number of times to repeat the animation.
         */
        public function get totalRepeatCount():int
        {
            return _totalRepeatCount;
        }

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		/**
		 * Starts playback.
		 */
		public function play():void
		{
			if (isAnimating)
				return;
			
			_type = _previousType;
			_previousType = AnimatorType.NO_ANIMATION;
			
			if (_elapsedTime == 0.0)
				dispatchEvent(new AnimationEvent(AnimationEvent.ANIMATION_STARTED_EVENT, this));
			else
				dispatchEvent(new AnimationEvent(AnimationEvent.ANIMATION_RESUMED_EVENT, this));
		}
		
		/**
		 * Resets the animation to all the values it had before it started playing.
		 */
		public function reset():void
		{
			if (isAnimating)
				stop();
			
			_current = _start;
			_elapsedTime = 0.0;
			_repeatCount = _totalRepeatCount;
		}
		
		/**
		 * Reverses the animation, effectively setting the start value to the target value and
		 * the target value to the start value.
		 */
		public function reverse():void
		{
			var swap:* = _target;
			_target = _start;
			_start = swap;
		}
		
		/**
		 * Starts the animation. This is simply a shorthand way to specify all the necessary parameters
		 * for playback. Play can be called instead if the properties are already set.
		 */
		public function start(startValue:*, targetValue:*, duration:Number, type:AnimatorType, repeatCount:int = 0):void
		{
			if (isAnimating)
				stop();
			
			_start = startValue;
			_target = targetValue;
			_duration = duration;
			_previousType = type;
			_totalRepeatCount = repeatCount;
			
			reset();
			play();
		}
		
		/**
		 * This should be called every frame to perform the animation.
		 *
		 * @param elapsed The amount of time that has elapsed since the last call to this.
		 */
		public function animate(elapsed:Number):void
		{
			if (_type == AnimatorType.NO_ANIMATION)
				return;
			
			_elapsedTime += elapsed;
			if (_elapsedTime > _duration)
			{
				if (_type == AnimatorType.PLAY_ANIMATION_ONCE || _repeatCount == 0)
				{
					finish();
					return;
				}
				
				if (_type == AnimatorType.PING_PONG_ANIMATION)
					reverse();
				
				// set the elapsed time to the leftover time
				
				_elapsedTime = Math.abs(_duration - _elapsedTime);
				
				// one less repeat
				if (_repeatCount > 0)
					_repeatCount--;
				
				dispatchEvent(new AnimationEvent(AnimationEvent.ANIMATION_REPEATED_EVENT, this));
			}
			
			_current = interpolate(_start, _target, _elapsedTime / _duration);
		}
		
		/**
		 * Set the current value to the target value instantly.
		 */
		public function finish():void
		{
			if (!isAnimating)
				return;
			
			if (_type == AnimatorType.PING_PONG_ANIMATION && _repeatCount & 1)
				_current = _start;
			else
				_current = _target;
			
			_previousType = _type;
			_type = AnimatorType.NO_ANIMATION;
			
			dispatchEvent(new AnimationEvent(AnimationEvent.ANIMATION_FINISHED_EVENT, this));
		}

		
		/**
		 * Stops playback. It can be resumed by calling Play.
		 */
		public function stop():void
		{
			if (!isAnimating)
				return;
			
			_previousType = _type;
			_type = AnimatorType.NO_ANIMATION;
			
			dispatchEvent(new AnimationEvent(AnimationEvent.ANIMATION_STOPPED_EVENT, this));
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
        protected function interpolate(start:*, end:*, time:Number):*
        {
            // Have to be careful to convert to numbers.
            var startN:Number = Number(start);
            var endN:Number = Number(end);

            // Do the interpolation.
            if ((endN - startN) < 0)
                return startN - ((startN - endN) * time);

            if(time > 1.0)
               time = 1.0;

            return startN + ((endN - startN) * time);
        }
    }
}