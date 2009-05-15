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
   }
}