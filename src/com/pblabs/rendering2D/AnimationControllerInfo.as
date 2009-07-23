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
   /**
    * Information describing an animation, for use in an AnimationController.
    * 
    * @see AnimationController.
    */ 
   public final class AnimationControllerInfo
   {
      /**
       * Sprite sheet containing this animation.
       */ 
      public var SpriteSheet:SpriteSheetComponent;
      
      /**
       * Used when setting animation states; a higher priority
       * animation will override a lower priority animation.
       */
      public var Priority:Number = 0.0;
      
      /**
       * If true, then the animation loops.
       */
      public var Loop:Boolean = true; 
      
      /**
       * Name of event to fire on the entity when this animation starts.
       */
      public var StartEvent:String;
      
      /**
       * Name of event to fire on the entity when this animation starts.
       */ 
      public var CompleteEvent:String;
      
      /**
       * The animation playback speed may be affected by many factors; this
       * set a maximum time period in ms for a frame to be displayed.
       */
      public var MaxFrameDelay:Number = 50;
   }
}
