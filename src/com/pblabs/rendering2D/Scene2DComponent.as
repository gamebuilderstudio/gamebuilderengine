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
   import com.pblabs.engine.core.*;
   import com.pblabs.engine.debug.*;
   
   import flash.display.*;
   import flash.geom.*;
   
   /**
    * Component to manage rendering a 2d scene. It queries a ISpatialManager2D
    * to determine what is visible.
    */ 
   public class Scene2DComponent extends BaseSceneComponent
   {
      /**
       * An optional object that the scene should follow around the world.
       */
      [EditorData(referenceType="componentReference")]
      public function get TrackObject():IDrawable2D
      {
         return _trackObject;
      }
      
      /**
       * @private
       */
      public function set TrackObject(value:IDrawable2D):void
      {
         _trackObject = value;
      }
      
      /**
       * The position of the center of the scene in the world.
       */
      public function get Position():Point
      {
         return _position;
      }
      
      /**
       * @private
       */
      public function set Position(value:Point):void
      {
         _position = new Point(value.x, value.y);
      }
      
      /**
       * @inheritDoc
       */
      public override function TransformWorldToScreen(point:Point, altitude:Number = 0):Point
      {
         var newPoint:Point = new Point();
         newPoint.x = (point.x - _position.x) + SceneView.width * 0.5;
         newPoint.y = (point.y - _position.y) + SceneView.height * 0.5;
         return newPoint;
      }
      
      /**
       * @inheritDoc
       */
      public override function TransformScreenToWorld(point:Point):Point
      {
         var newPoint:Point = new Point();
         newPoint.x = (point.x + _position.x) - SceneView.width * 0.5;
         newPoint.y = (point.y + _position.y) - SceneView.height * 0.5;
         return newPoint;
      }
      
      /**
       * @inheritDoc
       */
      protected override function _OnRemove():void 
      {
         super._OnRemove();
         
         // make sure we get rid of any potential references
         _trackObject = null;
      }
      
      /**
       * @inheritDoc
       */
      protected override function _Render():void
      {
         if (_trackObject)
         {
            _position.x = _trackObject.RenderPosition.x;
            _position.y = _trackObject.RenderPosition.y;
         }
         
         if (!SceneView)
            return;
         
         // Wipe all our existing renderables.
         SceneView.ClearDisplayObjects();

         // Figure out what will be drawn.
         var layerList:Array = new Array(LAYER_COUNT);
         var viewRect:Rectangle = new Rectangle(_position.x - SceneView.width * 0.5, _position.y - SceneView.height * 0.5, SceneView.width, SceneView.height);
         _BuildRenderList(viewRect, layerList);

         // So draw the layers in order.
         _DrawSortedLayers(layerList);
      }
      
      protected var _position:Point = new Point(0, 0);
      protected var _trackObject:IDrawable2D = null;
   }
}