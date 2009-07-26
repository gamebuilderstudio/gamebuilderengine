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
   import com.pblabs.engine.serialization.Enumerable;
   
   import flash.utils.Dictionary;
   
   /**
    * An enumeration that holds all the possible values for a type of animation.
    * 
    * @see Animator
    */
   public class AnimatorType extends Enumerable
   {
      /**
       * The value to use for animations that aren't currently animating.
       */
      public static const NoAnimation:AnimatorType = new AnimatorType();
      
      /**
       * The value to use for animations that should play once and then stop.
       */
      public static const PlayAnimationOnce:AnimatorType = new AnimatorType();
      
      /**
       * The value to use for animations that should play once, and the start over.
       */
      public static const LoopAnimation:AnimatorType = new AnimatorType();
      
      /**
       * The value to use for animations that should play once, then reverse and animate back
       * to the start value.
       */
      public static const PingPongAnimation:AnimatorType = new AnimatorType();
      
      private static var _typeMap:Dictionary = null;
      
      /**
       * @inheritDoc
       */
      public override function get TypeMap():Dictionary
      {
         if (!_typeMap)
         {
            _typeMap = new Dictionary();
            _typeMap["NoAnimation"] = NoAnimation;
            _typeMap["PlayAnimationOnce"] = PlayAnimationOnce;
            _typeMap["LoopAnimation"] = LoopAnimation;
            _typeMap["PingPongAnimation"] = PingPongAnimation;
         }
         
         return _typeMap;
      }
      
      /**
       * @inheritDoc
       */
      public override function get DefaultType():Enumerable
      {
         return NoAnimation;
      }
   }
}