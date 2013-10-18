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
    import com.pblabs.engine.PBE;
    import com.pblabs.engine.components.AnimatedComponent;
    import com.pblabs.engine.core.ProcessManager;
    import com.pblabs.engine.debug.Logger;
    import com.pblabs.engine.debug.Profiler;
    import com.pblabs.engine.entity.PropertyReference;
    import com.pblabs.rendering2D.spritesheet.SpriteContainerComponent;
    
    import flash.events.Event;
    import flash.utils.Dictionary;

    /**
     * Manage sprite sheet and frame selection based on named animation definitions.
     */
    public class AnimationController extends AnimatedComponent
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

        /**
         * Animations, indexed by name.
         *
         * @see AnimationControllerInfo
         */
        [TypeHint(type="com.pblabs.rendering2D.AnimationControllerInfo")]
        public var animations:Dictionary = new Dictionary();

        /**
         * Property indicating the duration of the current animation in ticks.
         */
        public var currentAnimationDurationReference:PropertyReference;

        /**
         * Property that indicates the name of the current animation.
         *
         * We read this each frame to determine what we should be playing.
         */
        public var currentAnimationReference:PropertyReference;

        /**
         * Property indicating the time at which the current animation started
         * (in virtual time ms). This can be used to make sure that animations
         * don't "lag" behind their actions if framerate is low.
         */
        public var currentAnimationStartTimeReference:PropertyReference;

        /**
         * Property to set with current frame of animation.
         */
        public var currentFrameReference:PropertyReference;

        /**
         * Name of animation to play when we have nothing better to do.
		 * Defaults to "Idle"
         */
        public var defaultAnimation:String = "Idle";

        /**
         * Property to set to the current sprite sheet.
         */
        public var spriteSheetReference:PropertyReference;
        
        /**
         * If true, do not advance the animation state.
         */
        public var paused:Boolean = false;

        /**
        * If set, the name of the event to listen to for animation changes on the 
        * owning entity. This is not required, but offers greater performance than 
        * checking for the name of the animation on every frame.
        * 
        * No data is read from this event, it is simply a signal to check the 
        * currentAnimationReference.
        */
        public var changeAnimationEvent:String;

        /**
         * Contains the currently playing animation if any.
         */
        private var _currentAnimation:AnimationControllerInfo;
        private var _currentAnimationDuration:Number = 0;
        private var _currentAnimationStartTime:Number = 0;
        private var _badAnimations:Dictionary;

        private var _changeAnimationEvent:String;

        private var _lastSpriteSheet:SpriteContainerComponent;
        private var _lastFrameIndex:int;
		private var _newAnimationSet : Boolean = false;
        
		public function get currentAnimationName():String{ 
			for( var key : * in animations)
			{
				if(_currentAnimation && animations[key] == _currentAnimation)
					return key as String;
			}
			return ""; 
		}
        public function set currentAnimationName(value:String):void
        {
			if(!value || value.length < 1){
				_currentAnimation = null;
				return;
			}
			
            var potentialAnim:AnimationControllerInfo = animations[value];
            if(!potentialAnim)
            {
                Logger.warn(this, "set currentAnimationName", "Couldn't find animation '" + value + "' to set.");
                return;
            }
			_newAnimationSet = true;
            setAnimation(potentialAnim);
        }
        
        override public function onFrame(elapsed:Number):void
        {
            if(paused)
                return;
            
            // Find an animation onFrame only if we're not bound to an event,
            // or we don't have an animation set.
            // The hash lookup and findProperty each frame gets expensive with a lot of 
            // animation components running.
            var nextAnim:AnimationControllerInfo = null;
			if(!_currentAnimation || (_newAnimationSet && _currentAnimation) || (changeAnimationEvent && !_currentAnimation))
                nextAnim = getNextAnimation();
            else
                nextAnim = _currentAnimation;

            if (!nextAnim){
                Logger.error(this, "playAnimation", "Unable to find default animation '" + defaultAnimation + "'!");
				return
			}

			var _currentTime : Number = ignoreTimeScale ? PBE.processManager.platformTime : PBE.processManager.virtualTime;
            // Expire current animation if it has finished playing and it's what we
            // want to keep playing.
            if (_currentAnimation !== nextAnim && _currentTime > (_currentAnimationStartTime + _currentAnimationDuration))
			{
				if (_currentAnimation && _currentAnimation.completeEvent)
				{
					var event:String = _currentAnimation.completeEvent;
					_currentAnimation = null;
					owner.eventDispatcher.dispatchEvent(new Event(event));
				} else {
					_currentAnimation = null;
				}
			}

            // If we do not have a current animation, start playing the next.
            if (!_currentAnimation || nextAnim.priority > _currentAnimation.priority)
                setAnimation(nextAnim);

            // If no current animation, then abort!
            if (!_currentAnimation)
            {
                Logger.warn(this, "OnFrame", "No current animation. Aborting!");
                return;
            }

            // Ok, we have a current, valid animation at this point. So let's set
            // the sprite sheet and frame properties.
            
			var targetCurFrame:int;

			// Fast path for single frame "animations".
            if (_currentAnimation.frameCount == 1)
            {
				targetCurFrame = _currentAnimation.getFrameByIndex(0);
				if (_currentAnimation.loop)
				{
					_currentAnimationStartTime = _currentTime;
				}
            }
            else
            {
                // If the sprite sheet was not initialized before we tick, the duration can be 0, causing us never to get past frame 0.
                if (_currentAnimationDuration == 0)
                    updateAnimationDuration();

                // Figure out what frame we are on.
                var frameTime:Number = _currentAnimationDuration / _currentAnimation.frameCount;
                if (frameTime > _currentAnimation.maxFrameDelay)
                    frameTime = _currentAnimation.maxFrameDelay;
    
				var animationAge:Number = _currentTime - _currentAnimationStartTime;
                var curFrame:int = Math.floor(animationAge / frameTime);
    			
				// Deal with clamping/looping.
                if (_currentAnimation.loop)
                {
					if(curFrame >= _currentAnimation.frameCount){
						_currentAnimationStartTime = _currentTime;
					}

					curFrame = curFrame % _currentAnimation.frameCount;
                }
                else
                {
                    if (curFrame >= _currentAnimation.frameCount)
                        curFrame = _currentAnimation.frameCount - 1;
                }
				
				targetCurFrame = _currentAnimation.getFrameByIndex(curFrame);
            }

            // Assign properties.
            // For performance, we only set the properties if they have changed since the last frame.
            if (targetCurFrame != _lastFrameIndex)
            {
                _lastFrameIndex = targetCurFrame;
                owner.setProperty(currentFrameReference, targetCurFrame);
            }
            
            if (_currentAnimation.spriteSheet && _currentAnimation.spriteSheet !== _lastSpriteSheet)
            {
                _lastSpriteSheet = _currentAnimation.spriteSheet;        
                owner.setProperty(spriteSheetReference, _currentAnimation.spriteSheet);
            }
			
			_newAnimationSet = false;
        }
        
        /**
         * Set the current animation to specified info.
         */
        public function setAnimation(ai:AnimationControllerInfo):void
        {
            Profiler.enter("AnimationController.SetAnimation");
            
            // Fire stop event.
            if (_currentAnimation && _currentAnimation.completeEvent)
                owner.eventDispatcher.dispatchEvent(new Event(_currentAnimation.completeEvent));

            _currentAnimation = ai;

            // Fire start event.
            if (_currentAnimation.startEvent)
                owner.eventDispatcher.dispatchEvent(new Event(_currentAnimation.startEvent));

            if (!ai.spriteSheet){
				Logger.warn(this, "setAnimation", "The animation has no sprite sheet, if this is intended ignore!");
			}

            // Note when we started.
            if (currentAnimationStartTimeReference)
                _currentAnimationStartTime = owner.getProperty(currentAnimationStartTimeReference);
            else
                _currentAnimationStartTime = ignoreTimeScale ? PBE.processManager.platformTime : PBE.processManager.virtualTime;

            updateAnimationDuration();

            Profiler.exit("AnimationController.SetAnimation");
        }
        
        protected function updateAnimationDuration():void
        {
            // Update our duration information.
            if (currentAnimationDurationReference && currentAnimationDurationReference.property != "")
                _currentAnimationDuration = owner.getProperty(currentAnimationDurationReference) * ProcessManager.TICK_RATE_MS;
            else if(_currentAnimation && _currentAnimation.spriteSheet)
                _currentAnimationDuration = _currentAnimation.spriteSheet.frameCount * (1000/_currentAnimation.frameRate);
			else
				_currentAnimationDuration = 0;
        }

        protected function getNextAnimation():AnimationControllerInfo
        {
            var nextAnim:AnimationControllerInfo = null;
            if (currentAnimationReference && currentAnimationReference.property && currentAnimationReference.property.length > 0)
            {
                var nextAnimName:String = owner.getProperty(currentAnimationReference);
                nextAnim = animations[nextAnimName];
				if(nextAnim && nextAnim != _currentAnimation){
					setAnimation(nextAnim);
				}
            }
            else
            {
                nextAnim = animations[defaultAnimation];
            }

            // Go to default animation if we've nothing better to do.
            if (nextAnim == null)
            {
                // Supressing duplicate log messages for animations that we know are already missing.
                // A log message per frame is pretty expensive.
                if (!_badAnimations)
                    _badAnimations = new Dictionary();

                if (!_badAnimations[nextAnimName])
                {
                    Logger.warn(this, "OnFrame", "Animation '" + nextAnimName + "' not found, going with default animation '" + defaultAnimation + "'.");
                    _badAnimations[nextAnimName] = true;
                }

                nextAnim = animations[defaultAnimation];
            }
            
            return nextAnim;
        }

        override protected function onAdd(): void
        {
            super.onAdd();
            
            if (owner.eventDispatcher && changeAnimationEvent)
                owner.eventDispatcher.addEventListener(changeAnimationEvent, animationChangedHandler);
        }
        
        override protected function onRemove() : void
        {
            super.onRemove();
            
            if (owner.eventDispatcher && changeAnimationEvent)
                owner.eventDispatcher.removeEventListener(changeAnimationEvent, animationChangedHandler);
			
			var animationKeys : Array = [];
			for(var key : * in animations)
			{
				animationKeys.push( key );
			}
			
			for(var i : int=0; i < animationKeys.length; i++)
			{
				var animContrl : AnimationControllerInfo = animations[ animationKeys[i] ] as AnimationControllerInfo;
				animContrl.spriteSheet = null;
				delete animations[ animationKeys[i] ];
			}
        }
        
        private function animationChangedHandler(event:Event):void
        {
            // This is all we need to do for the onFrame method to pick up that the 
            // animation is missing and load the current one based on the property references.
            _currentAnimation = null;
        }
       
    }
}

