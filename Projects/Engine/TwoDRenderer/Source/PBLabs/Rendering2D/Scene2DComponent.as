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
   import PBLabs.Engine.Core.*;
   
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
         if (SceneView == null)
            return _position;
         
         return new Point(-SceneView.x + (SceneView.width * 0.5), -SceneView.y + (SceneView.height * 0.5));
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
         if (_trackObject != null)
         {
            _position.x = _trackObject.RenderPosition.x;
            _position.y = _trackObject.RenderPosition.y;
         }
         
         if (SceneView == null)
            return;
         
         // Wipe all our existing renderables.
         while (SceneView.numChildren)
            SceneView.removeChildAt(0);

         // Figure out what will be drawn.
         var layerList:Array = new Array(LAYER_COUNT);
         var viewRect:Rectangle = new Rectangle(_position.x - SceneView.width * 0.5, _position.y - SceneView.height * 0.5, SceneView.width, SceneView.height);
         _BuildRenderList(viewRect, layerList);

         // So draw the layers in order.
         _DrawSortedLayers(layerList);
      }
      
      private var _position:Point = new Point(0, 0);
      private var _trackObject:IDrawable2D = null;
   }
}