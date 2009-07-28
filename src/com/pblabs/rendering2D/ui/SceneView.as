/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.rendering2D.ui
{
   import com.pblabs.engine.core.Global;
   import flash.display.*;
   
   /**
    * This class can be set as the SceneView on the BaseSceneComponent class and is used
    * as the canvas to draw the objects that make up the scene.
    * 
    * <p>Currently this is just a stub, and exists for clarity and potential expandability in
    * the future.</p>
    */
   public class SceneView extends Sprite implements IUITarget
   {
      override public function get width():Number
      {
         return _width;
      }
      
      override public function set width(value:Number):void
      {
         _width = value;
      }
      
      override public function get height():Number
      {
         return _height;
      }
      
      override public function set height(value:Number):void
      {
         _height = value;
      }
      
      public function SceneView()
      {
         Global.mainStage.addChild(this);
      }
      
      public function addDisplayObject(dobj:DisplayObject):void
      {
      	addChild(dobj);
      }
      
      public function clearDisplayObjects():void
      {
      	while(numChildren)
      	   removeChildAt(0);
      }
      
      private var _width:Number = 0;
      private var _height:Number = 0;
   }
}