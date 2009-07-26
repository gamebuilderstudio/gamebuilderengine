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
   import com.pblabs.engine.entity.*;
   import com.pblabs.engine.components.*;
   import com.pblabs.engine.debug.*;
   import com.pblabs.engine.core.*;
   import flash.events.*;
   
   /**
    * Manage sprite sheet and frame selection based on named animation definitions.
    */
   public class AnimationController extends AnimatedComponent
   {
      /**
       * Animations, indexed by name.
       * 
       * @see AnimationControllerInfo
       */
      [TypeHint(type="com.pblabs.rendering2D.AnimationControllerInfo")]
      public var Animations:Array = new Array();
      
      /**
       * Name of animation to play when we have nothing better to do.
       */
      public var DefaultAnimation:String = "Idle"; 
      
      /**
       * Property to set with name of sprite sheet.
       */
      public var SpriteSheetReference:PropertyReference;
      
      /**
       * Property to set with current frame of animation.
       */
      public var CurrentFrameReference:PropertyReference;

      /**
       * Property that indicates the name of the current animation.
       * 
       * We read this each frame to determine what we should be playing.
       */
      public var CurrentAnimationReference:PropertyReference;
      
      /**
       * Property indicating the duration of the current animation in ticks.
       */
      public var CurrentAnimationDurationReference:PropertyReference;
      
      /**
       * Property indicating the time at which the current animation started
       * (in virtual time ms). This can be used to make sure that animations
       * don't "lag" behind their actions if framerate is low.
       */
      public var CurrentAnimationStartTimeReference:PropertyReference;
      
      public override function onFrame(elapsed:Number) : void
      {
         // Check for a new animation.
         var nextAnim:AnimationControllerInfo = null;
         if(CurrentAnimationReference)
         {
            var nextAnimName:String = owner.getProperty(CurrentAnimationReference);
            nextAnim = Animations[nextAnimName];
         }
         else
         {
            nextAnim = Animations[DefaultAnimation];
         }
         
         // Go to default animation if we've nothing better to do.
         if(!nextAnim)
         {
           Logger.printWarning(this, "OnFrame", "Animation '" + nextAnimName + "' not found, going with default animation '" + DefaultAnimation + "'.");
           nextAnim = Animations[DefaultAnimation];
         }
         
         if(!nextAnim)
            throw new Error("Unable to find default animation '" + DefaultAnimation + "'!");
           
         // Expire current animation if it has finished playing and it's what we
         // want to keep playing.
         if(ProcessManager.instance.virtualTime > (_CurrentAnimationStartTime + _CurrentAnimationDuration))
            _CurrentAnimation = null;
         
         // If we do not have a current animation, start playing the next.
         if(!_CurrentAnimation || nextAnim.Priority > _CurrentAnimation.Priority)
            setAnimation(nextAnim);
           
         // If no current animation, then abort!
         if(!_CurrentAnimation)
         {
            Logger.printWarning(this, "OnFrame", "No current animation. Aborting!");
            return;
         }
         
         // Ok, we have a current, valid animation at this point. So let's set
         // the sprite sheet and frame properties.
         
         // Figure out what frame we are on.
         var frameTime:Number = _CurrentAnimationDuration / _CurrentAnimation.SpriteSheet.frameCount;
         if(frameTime > _CurrentAnimation.MaxFrameDelay)
            frameTime = _CurrentAnimation.MaxFrameDelay;

         var animationAge:Number = ProcessManager.instance.virtualTime - _CurrentAnimationStartTime;
         var curFrame:int = Math.floor(animationAge/frameTime);
         
         // Deal with clamping/looping.
         if(!_CurrentAnimation.Loop)
         {
           if(curFrame >= _CurrentAnimation.SpriteSheet.frameCount)
              curFrame = _CurrentAnimation.SpriteSheet.frameCount - 1;
         }
         else
         {
            var wasFrame:int = curFrame;
            curFrame = curFrame % _CurrentAnimation.SpriteSheet.frameCount;
         }
         
         // Assign properties.
         owner.setProperty(SpriteSheetReference, _CurrentAnimation.SpriteSheet);
         owner.setProperty(CurrentFrameReference, curFrame);
      }
      
      /**
       * Set the current animation to specified info.
       */ 
      public function setAnimation(ai:AnimationControllerInfo):void
      {
         Profiler.enter("AnimationController.SetAnimation");
         
         // Fire stop event.
         if(_CurrentAnimation && _CurrentAnimation.CompleteEvent)
            owner.eventDispatcher.dispatchEvent(new Event(_CurrentAnimation.CompleteEvent));

         _CurrentAnimation = ai;
         
         // Fire start event.
         if(_CurrentAnimation.StartEvent)
            owner.eventDispatcher.dispatchEvent(new Event(_CurrentAnimation.StartEvent));
         
         if(!ai.SpriteSheet)
            throw new Error("Animation had no sprite sheet!");
         
         // Note when we started.
         if(CurrentAnimationStartTimeReference)
            _CurrentAnimationStartTime = owner.getProperty(CurrentAnimationStartTimeReference);
         else
            _CurrentAnimationStartTime = ProcessManager.instance.virtualTime;
         
         // Update our duration information.
         if(CurrentAnimationDurationReference)
            _CurrentAnimationDuration = owner.getProperty(CurrentAnimationDurationReference) * ProcessManager.TICK_RATE_MS;
         else
            _CurrentAnimationDuration = ai.SpriteSheet.frameCount * ProcessManager.TICK_RATE_MS;
         
         Profiler.exit("AnimationController.SetAnimation");
      }
      
      /**
       * Contains the currently playing animation if any.
       */ 
      private var _CurrentAnimation:AnimationControllerInfo;

      private var _CurrentAnimationStartTime:Number = 0;
      private var _CurrentAnimationDuration:Number = 0;
   }
}