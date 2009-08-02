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
	import com.pblabs.engine.components.AnimatedComponent;
	import com.pblabs.engine.core.ProcessManager;
	import com.pblabs.engine.debug.Logger;
	import com.pblabs.engine.debug.Profiler;
	import com.pblabs.engine.entity.PropertyReference;
	
	import flash.events.Event;

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
        public var animations:Array = new Array();

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
         */
        public var defaultAnimation:String = "Idle";

        /**
         * Property to set with name of sprite sheet.
         */
        public var spriteSheetReference:PropertyReference;

        /**
         * Contains the currently playing animation if any.
         */
        private var _currentAnimation:AnimationControllerInfo;
        private var _currentAnimationDuration:Number = 0;
        private var _currentAnimationStartTime:Number = 0;

        override public function onFrame(elapsed:Number):void
        {
            // Check for a new animation.
            var nextAnim:AnimationControllerInfo = null;
            if (currentAnimationReference)
            {
                var nextAnimName:String = owner.getProperty(currentAnimationReference);
                nextAnim = animations[nextAnimName];
            }
            else
            {
                nextAnim = animations[defaultAnimation];
            }

            // Go to default animation if we've nothing better to do.
            if (nextAnim == null)
            {
                Logger.printWarning(this, "OnFrame", "Animation '" + nextAnimName + "' not found, going with default animation '" + defaultAnimation + "'.");
                nextAnim = animations[defaultAnimation];
            }

            if (!nextAnim)
                throw new Error("Unable to find default animation '" + defaultAnimation + "'!");

            // Expire current animation if it has finished playing and it's what we
            // want to keep playing.
            if (ProcessManager.instance.virtualTime > (_currentAnimationStartTime + _currentAnimationDuration))
                _currentAnimation = null;

            // If we do not have a current animation, start playing the next.
            if (!_currentAnimation || nextAnim.priority > _currentAnimation.priority)
                setAnimation(nextAnim);

            // If no current animation, then abort!
            if (!_currentAnimation)
            {
                Logger.printWarning(this, "OnFrame", "No current animation. Aborting!");
                return;
            }

            // Ok, we have a current, valid animation at this point. So let's set
            // the sprite sheet and frame properties.

            // Figure out what frame we are on.
            var frameTime:Number = _currentAnimationDuration / _currentAnimation.spriteSheet.frameCount;
            if (frameTime > _currentAnimation.maxFrameDelay)
                frameTime = _currentAnimation.maxFrameDelay;

            var animationAge:Number = ProcessManager.instance.virtualTime - _currentAnimationStartTime;
            var curFrame:int = Math.floor(animationAge / frameTime);

            // Deal with clamping/looping.
            if (_currentAnimation.loop)
            {
                var wasFrame:int = curFrame;
                curFrame = curFrame % _currentAnimation.spriteSheet.frameCount;
            }
            else
            {
                if (curFrame >= _currentAnimation.spriteSheet.frameCount)
                    curFrame = _currentAnimation.spriteSheet.frameCount - 1;
            }

            // Assign properties.
            owner.setProperty(spriteSheetReference, _currentAnimation.spriteSheet);
            owner.setProperty(currentFrameReference, curFrame);
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

            if (!ai.spriteSheet)
                throw new Error("Animation had no sprite sheet!");

            // Note when we started.
            if (currentAnimationStartTimeReference)
                _currentAnimationStartTime = owner.getProperty(currentAnimationStartTimeReference);
            else
                _currentAnimationStartTime = ProcessManager.instance.virtualTime;

            // Update our duration information.
            if (currentAnimationDurationReference)
                _currentAnimationDuration = owner.getProperty(currentAnimationDurationReference) * ProcessManager.TICK_RATE_MS;
            else
                _currentAnimationDuration = ai.spriteSheet.frameCount * ProcessManager.TICK_RATE_MS;
            
            //trace("Age at start was " + (ProcessManager.instance.virtualTime - _currentAnimationStartTime));
            
            Profiler.exit("AnimationController.SetAnimation");
        }
    }
}