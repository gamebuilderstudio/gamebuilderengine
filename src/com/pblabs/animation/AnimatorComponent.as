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
   import com.pblabs.engine.components.AnimatedComponent;
   import com.pblabs.engine.entity.PropertyReference;
   import flash.utils.Dictionary;
   
   /**
    * Component for animating any value on its owner.
    */
   public class AnimatorComponent extends AnimatedComponent
   {
      /**
       * A reference to the property that will be animated.
       */
      public var Reference:PropertyReference = null;
      
      /**
       * A list of all the animation that can be played by this component.
       */
      [TypeHint(type="com.pblabs.animation.Animator")]
      public var Animations:Dictionary = null;
      
      /**
       * The name of the animation to automatically start playing when the component
       * is registered.
       */
      public var DefaultAnimation:String = "Idle";
      
      /**
       * Whether or not to start the animation when the component is registered.
       */
      [EditorData(defaultValue="true")]
      public var AutoPlay:Boolean = true;
      
      /**
       * @inheritDoc
       */
      public override function OnFrame(elapsed:Number):void
      {
         if (_currentAnimation)
         {
            _currentAnimation.Animate(elapsed);
            Owner.SetProperty(Reference, _currentAnimation.CurrentValue);            
         }
      }
      
      /**
       * Plays an animation that is on this component.
       * 
       * @param animation The name of the animation in the Animations dictionary
       * to play.
       * @param startValue The value to start at. If this is null (the default), the
       * start value won't be changed.
       */
      public function Play(animation:String, startValue:*=null):void
      {
         _currentAnimation = Animations[animation];
         if (!_currentAnimation)
            return;
         
         if (startValue)
            _currentAnimation.StartValue = startValue;
         
         _currentAnimation.Reset();
         _currentAnimation.Play();
      }
      
      /**
       * @inheritDoc
       */
      protected override function _OnReset():void
      {
         if (!AutoPlay || _currentAnimation)
            return;
         
         Play(DefaultAnimation);
      }
      
      private var _currentAnimation:Animator = null;
   }
}