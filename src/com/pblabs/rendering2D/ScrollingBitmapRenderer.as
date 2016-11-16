/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2012 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.rendering2D
{
	import com.pblabs.engine.PBE;
	import com.pblabs.engine.core.ObjectType;
	import com.pblabs.engine.debug.Logger;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class ScrollingBitmapRenderer extends SpriteRenderer
	{
		
		//-------------------------------------------------------------------------
		// public variable declarations
		//-------------------------------------------------------------------------		
		[EditorData(inspectable="true")]
		public var scrollSpeed:Point = new Point(0,0);
		[EditorData(inspectable="true")]
		public var autoCorrectImageSize : Boolean = true;
		
		//-------------------------------------------------------------------------
		// private variable declarations
		//-------------------------------------------------------------------------
		
		protected var scrollRect:Rectangle = new Rectangle();	// will hold the drawing area
		protected var _scratchPosition : Point = new Point();
		protected var _m : Matrix = new Matrix();
		protected var _painted : Boolean = false;

		//-------------------------------------------------------------------------
		// public methods
		//-------------------------------------------------------------------------				
		/**
		 * constructor
		 * 
		 * @param bitmap:Bitmap is provided bitmap for repeating background
		 * @param width:int is Scrolling Bitmap width dimension
		 * @param height:int is Scrolling Bitmap height dimension
		 */
		public function ScrollingBitmapRenderer()
		{
			// call inherited constructor
			super();
		}
		
		override public function set bitmapData(value:BitmapData):void
		{
			super.bitmapData = value;
			bitmap.visible = false;
			_painted = false;
		}
		
		public override function isPixelPathActive(objectToScreen:Matrix):Boolean
		{
			return false;
		}
		
		public override function onFrame(deltaTime:Number):void
		{
			// Lookup and apply properties. This only makes adjustments to the
			// underlying DisplayObject if necessary.
			if (!displayObject)
				return;
			
			updateProperties();
			
			// adjust scroll offset using the scrollSpeed
			_scratchPosition.x += (scrollSpeed.x * deltaTime); 
			_scratchPosition.y += (scrollSpeed.y * deltaTime);	
			
			if(PBE.IN_EDITOR) 
				_scratchPosition.x = _scratchPosition.y = 0;
			
			offsetImage(_scratchPosition.x, _scratchPosition.y);
			
			// Now that we've read all our properties, apply them to our transform.
			if (_transformDirty || PBE.IN_EDITOR) // || PBE.IN_EDITOR is here to get the scrolling renderer to repaint while in editor on load of project
				updateTransform();
		}
		
		override protected function onAdd():void
		{
			snapToNearestPixels = false;
			super.onAdd();
		}
		
		protected function offsetImage(x : Number, y : Number):void
		{
			if(!bitmapData) 
				return;
			
			if(!size || size.x == 0 || size.y == 0) 
				return;
			
			// determine the right drawing rectangle area of the bitmapData object with all display info 
			// for the copyPixel command
			// determine x offset of rectangle draw area 
			var dx:Number = x - (Math.floor(x/bitmapData.width)*bitmapData.width);
			//if(!_painted)
			//dx += scrollPosition.x;
			scrollRect.x = dx;
			if((int(dx) % bitmapData.width) == 0)
				scrollRect.x = 0;
			// determine y offset of rectangle draw area 
			var dy:Number = y - (Math.floor((y)/bitmapData.height)*bitmapData.height);
			//if(!_painted)
			//dy += scrollPosition.y;
			scrollRect.y = dy;			
			if((int(dy) % bitmapData.height) == 0)
				scrollRect.y = 0;
			
			_m.identity();
			_m.translate(scrollRect.x, scrollRect.y);
			// Position to match scene view.
			(_displayObject as Sprite).graphics.clear();
			(_displayObject as Sprite).graphics.beginBitmapFill(bitmapData, _m, true, true); 
			(_displayObject as Sprite).graphics.drawRect(0,0, _size.x, _size.y);
			(_displayObject as Sprite).graphics.endFill();
			_displayObject.scaleX = _scale.x;
			_displayObject.scaleY = _scale.y;
			
			if(!_painted)
			{
				_painted = true;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function updateTransform(updateProps:Boolean = false):void
		{
			if(!displayObject || !bitmapData)
				return;
			
			super.updateTransform(updateProps);
			
			_displayObject.scaleX = _scale.x;
			_displayObject.scaleY = _scale.y;
			
			_transformDirty = false;
		}

		/**
		 * Is the rendered object opaque at the request position in screen space?
		 * @param pos Location in world space we are curious about.
		 * @return True if object is opaque there.
		 */
		override public function pointOccupied(worldPosition:Point, mask:ObjectType):Boolean
		{
			if (!_displayObject || !scene)
				return super.pointOccupied(worldPosition, mask);
			
			// Sanity check.
			if(_displayObject.stage == null)
				Logger.warn(this, "pointOccupied", "DisplayObject is not on stage, so hitTestPoint will probably not work right.");
			
			// This is the generic version, which uses hitTestPoint. hitTestPoint
			// takes a coordinate in screen space, so do that.
			worldPosition = scene.transformWorldToScreen(worldPosition);
			return _displayObject.hitTestPoint(worldPosition.x, worldPosition.y, true);
		}
	}
}
