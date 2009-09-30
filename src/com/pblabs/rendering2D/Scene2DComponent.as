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
	import flash.geom.Point;
	import flash.geom.Rectangle;
   
	/**
	* Component to manage rendering a 2d scene. It queries a ISpatialManager2D
	* to determine what is visible.
	*/ 
	public class Scene2DComponent extends BaseSceneComponent
	{
		// fixme - HW - fix the tab spacing in this file
		
		protected var _position:Point = new Point(0, 0);
		protected var _trackObject:IDrawable2D = null;
		protected var _alignment:String = SceneAlignment.DEFAULT_ALIGNMENT;

		public function get alignment():String
		{
			return _alignment;
		}

		public function set alignment(value:String):void
		{
			_alignment = value;
		}

	/**
	 * An optional object that the scene should follow around the world.
	 */
	[EditorData(referenceType="componentReference")]
      public function get trackObject():IDrawable2D
      {
         return _trackObject;
      }
      
      /**
       * @private
       */
      public function set trackObject(value:IDrawable2D):void
      {
         _trackObject = value;
      }
      
      /**
       * The position of the center of the scene in the world.
       */
      public function get position():Point
      {
         return _position;
      }
      
      /**
       * @private
       */
      public function set position(value:Point):void
      {
         _position = new Point(value.x, value.y);
      }
      
      /**
       * @inheritDoc
       */
      override public function transformWorldToScreen(point:Point, altitude:Number = 0, scrollFactor:Point = null):Point
      {
         var newPoint:Point = new Point();
		 
		 SceneAlignment.calculate(newPoint, _alignment, sceneView.width, sceneView.height);
         
         if (scrollFactor == null) 
         {
			newPoint.x += (point.x - _position.x);
            newPoint.y += (point.y - _position.y);
         }
         else
         {
            newPoint.x += (point.x - _position.x * scrollFactor.x);
            newPoint.y += (point.y - _position.y * scrollFactor.y);
         }
		 
         return newPoint;
      }
      
      /**
       * @inheritDoc
       */
      override public function transformScreenToWorld(point:Point, scrollFactor:Point = null):Point
      {
         var newPoint:Point = new Point();
         
		 SceneAlignment.calculate(newPoint, _alignment, sceneView.width, sceneView.height);
		 
         if (scrollFactor == null)
         {
            newPoint.x = (point.x + _position.x) - newPoint.x;
            newPoint.y = (point.y + _position.y) - newPoint.y;
         }
         else
         {
            newPoint.x = (point.x + _position.x * scrollFactor.x) - newPoint.x;
            newPoint.y = (point.y + _position.y * scrollFactor.y) - newPoint.y;
         }
		 
         return newPoint;
      }
      
      /**
       * @inheritDoc
       */
      override protected function onRemove():void 
      {
         super.onRemove();
         
         // make sure we get rid of any potential references
         _trackObject = null;
      }
      
      /**
       * @inheritDoc
       */
      override protected function render():void
      {
         if (_trackObject)
         {
            _position.x = _trackObject.renderPosition.x;
            _position.y = _trackObject.renderPosition.y;
         }
         
         if (!sceneView)
            return;
         
         // Wipe all our existing renderables.
         sceneView.clearDisplayObjects();

         // Figure out what will be drawn.
         var layerList:Array = new Array(LAYER_COUNT);
         var viewRect:Rectangle = new Rectangle(_position.x - sceneView.width * 0.5, _position.y - sceneView.height * 0.5, sceneView.width, sceneView.height);
         buildRenderList(viewRect, layerList);

         // So draw the layers in order.
         drawSortedLayers(layerList);
      }
   }
}