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
      public static const NO_ANIMATION:AnimatorType = new AnimatorType();
      
      /**
       * The value to use for animations that should play once and then stop.
       */
      public static const PLAY_ANIMATION_ONCE:AnimatorType = new AnimatorType();
      
      /**
       * The value to use for animations that should play once, and then start over.
       */
      public static const LOOP_ANIMATION:AnimatorType = new AnimatorType();
      
      /**
       * The value to use for animations that should play once, then reverse and animate back
       * to the start value.
       */
      public static const PING_PONG_ANIMATION:AnimatorType = new AnimatorType();
      
      private static var _typeMap:Dictionary = null;
      
      /**
       * @inheritDoc
       */
      override public function get typeMap():Dictionary
      {
         if (!_typeMap)
         {
            _typeMap = new Dictionary();
            _typeMap["NO_ANIMATION"] = NO_ANIMATION;
            _typeMap["PLAY_ANIMATION_ONCE"] = PLAY_ANIMATION_ONCE;
            _typeMap["LOOP_ANIMATION"] = LOOP_ANIMATION;
            _typeMap["PING_PONG_ANIMATION"] = PING_PONG_ANIMATION;
         }
         
         return _typeMap;
      }
      
      /**
       * @inheritDoc
       */
      override public function get defaultType():Enumerable
      {
         return NO_ANIMATION;
      }
   }
}