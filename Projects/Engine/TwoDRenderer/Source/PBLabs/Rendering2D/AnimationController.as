/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Rendering2D
{
   import PBLabs.Engine.Entity.*;
   import PBLabs.Engine.Components.*;
   import PBLabs.Engine.Debug.*;
   import PBLabs.Engine.Core.*;
   
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
      [TypeHint(type="PBLabs.Rendering2D.AnimationControllerInfo")]
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
      
      public override function OnFrame(elapsed:Number) : void
      {
         // Check for a new animation.
         var nextAnim:AnimationControllerInfo = null;
         if(CurrentAnimationReference)
         {
            var nextAnimName:String = Owner.GetProperty(CurrentAnimationReference);
            nextAnim = Animations[nextAnimName];
         }
         
         // Go to default animation if we've nothing better to do.
         if(nextAnim == null)
         {
           Logger.PrintWarning(this, "OnFrame", "Animation '" + nextAnimName + "' not found, going with default animation '" + DefaultAnimation + "'.");
           nextAnim = Animations[DefaultAnimation];
         }
         
         if(!nextAnim)
            throw new Error("Unable to find default animation '" + DefaultAnimation + "'!");
           
         // Expire current animation if it has finished playing.
         if(ProcessManager.Instance.VirtualTime > (_CurrentAnimationStartTime + _CurrentAnimationDuration))
            _CurrentAnimation = null;
         
         // If we do not have a current animation, start playing the next.
         if(!_CurrentAnimation)
            SetAnimation(nextAnim);
           
         // If no current animation, then abort!
         if(!_CurrentAnimation)
         {
            Logger.PrintWarning(this, "OnFrame", "No current animation. Aborting!");
            return;
         }
         
         // Ok, we have a current, valid animation at this point. So let's set
         // the sprite sheet and frame properties.
         
         // Figure out what frame we are on.
         var frameTime:Number = _CurrentAnimationDuration / _CurrentAnimation.SpriteSheet.FrameCount;

         var animationAge:Number = ProcessManager.Instance.VirtualTime - _CurrentAnimationStartTime;
         var curFrame:int = Math.floor(animationAge/frameTime);
         
         // Deal with clamping/looping.
         if(!_CurrentAnimation.Loop)
         {
           if(curFrame >= _CurrentAnimation.SpriteSheet.FrameCount)
              curFrame = _CurrentAnimation.SpriteSheet.FrameCount - 1;
         }
         else
         {
            var wasFrame:int = curFrame;
            curFrame = curFrame % _CurrentAnimation.SpriteSheet.FrameCount;
         }
         
         // Assign properties.
         Owner.SetProperty(SpriteSheetReference, _CurrentAnimation.SpriteSheet);
         Owner.SetProperty(CurrentFrameReference, curFrame);
      }
      
      /**
       * Set the current animation to specified info.
       */ 
      public function SetAnimation(ai:AnimationControllerInfo):void
      {
         _CurrentAnimation = ai;
         
         if(!ai.SpriteSheet)
            throw new Error("Animation had no sprite sheet!");
         
         // Note when we started.
         if(CurrentAnimationStartTimeReference)
            _CurrentAnimationStartTime = Owner.GetProperty(CurrentAnimationStartTimeReference);
         else
            _CurrentAnimationStartTime = ProcessManager.Instance.VirtualTime;
         
         // Update our duration information.
         if(CurrentAnimationDurationReference)
            _CurrentAnimationDuration = Owner.GetProperty(CurrentAnimationDurationReference) * ProcessManager.TICK_RATE_MS;
         else
            _CurrentAnimationDuration = ai.SpriteSheet.FrameCount * ProcessManager.TICK_RATE_MS;
         
      }
      
      /**
       * Contains the currently playing animation if any.
       */ 
      private var _CurrentAnimation:AnimationControllerInfo;

      private var _CurrentAnimationStartTime:Number = 0;
      private var _CurrentAnimationDuration:Number = 0;
   }
}