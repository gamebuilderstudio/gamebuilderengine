/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package PBLabs.Rendering2D.UI
{
   import PBLabs.Engine.Core.Global;
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
      public override function get width():Number
      {
         return _width;
      }
      
      public override function set width(value:Number):void
      {
         _width = value;
      }
      
      public override function get height():Number
      {
         return _height;
      }
      
      public override function set height(value:Number):void
      {
         _height = value;
      }
      
      public function SceneView()
      {
         Global.MainStage.addChild(this);
      }
      
      public function AddDisplayObject(dobj:DisplayObject):void
      {
      	addChild(dobj);
      }
      
      public function ClearDisplayObjects():void
      {
      	while(numChildren)
      	   removeChildAt(0);
      }
      
      private var _width:Number = 0;
      private var _height:Number = 0;
   }
}