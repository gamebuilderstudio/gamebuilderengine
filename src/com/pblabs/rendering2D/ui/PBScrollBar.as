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
	import com.pblabs.engine.PBUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	/**
	 * Simple Scroll Bar for use in creating simple UIs.
	 * 
	 * Change properties and call refresh() for them to take effect.
	 */
	public class PBScrollBar extends Sprite
	{
		protected var _extents:Rectangle;
		protected var _dragExtents:Rectangle;
		protected var _track:Sprite;
		protected var _thumb:Sprite;
		
		protected var _tf:TextField;
		
		private var _progress:Number;
		
		public function PBScrollBar()
		{
			init();
		}
		
		protected function init():void
		{
			_extents = new Rectangle(0,0,5,100);
			_track = new Sprite();
			_thumb = new Sprite();
			
			_track.buttonMode = _thumb.buttonMode = true;
			_track.useHandCursor = _thumb.useHandCursor = true;
			
			addChild(_track);
			addChild(_thumb);
			
			addListeners();
			
			refresh();
		}
		
		protected function addListeners():void
		{
			_track.addEventListener(MouseEvent.CLICK, onTrackClick, false, 0, true);
			_thumb.addEventListener(MouseEvent.MOUSE_DOWN, onThumbDown, false, 0, true);
			_thumb.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
		}
		
		protected function calcThumbProgress():void 
		{
			_progress = _thumb.y / (_dragExtents.height - _thumb.height);
		}
		
		protected function scrollTextField():void
		{
			if(!_tf) return;
			
			_tf.scrollV = _tf.maxScrollV * _progress;
		}
		
		protected function startDragging():void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			stage.addEventListener(Event.ENTER_FRAME, onDragging, false, 0, true);
			
			_dragExtents = new Rectangle(0,0,0,(_extents.height-_thumb.height-1));
			
			_thumb.startDrag(false, _dragExtents);
		}
		
		protected function stopDragging():void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.removeEventListener(Event.ENTER_FRAME, onDragging);
			
			_thumb.stopDrag();
		}
		
		protected function onTrackClick(event:MouseEvent):void
		{
			stopDragging();

			_progress = event.localY / (_extents.height - _thumb.height);
			
			refresh();
			scrollTextField();
		}
		
		protected function onThumbDown(event:MouseEvent):void
		{
			startDragging();
		}
		
		protected function onMouseUp(event:MouseEvent):void
		{
			stopDragging();
		}
		
		protected function onDragging(event:Event):void
		{
			calcThumbProgress();
			scrollTextField();
		}
		
		/**
		 * Applies all changes and updates appearance of the scroll bar.
		 * 
		 * We have this as an explicit function call so that there
		 * isn't any overhead if many properties are changed.
		 */
		public function refresh():void
		{
			if(_tf && _tf.maxScrollV > 1)	// If we need to scroll
			{
				// Redraw our track.
				_track.graphics.clear();
				_track.graphics.beginFill(0xEEEEEE,0);
				_track.graphics.drawRect(_extents.x, _extents.y, _extents.width, _extents.height);
				_track.graphics.endFill();
			
				// Redraw our thumb.
				_thumb.graphics.clear();
				_thumb.graphics.beginFill(0xCCCCCC);
				_thumb.graphics.drawRoundRect
					(
						_extents.x+1, 
						_extents.y+1, 
						_extents.width-2, _extents.height/10, _extents.width, 
						_extents.width
					);
				_thumb.graphics.endFill();
				
				_thumb.y = PBUtil.clamp
					(
						(_extents.height - (_extents.height/10)) * _progress - 1, 
						0, 
						_extents.height - _thumb.height - 1
					);
				
			}
			else
			{
				_track.graphics.clear();
				_thumb.graphics.clear();
			}
		}

		/**
		 * Location and size of label, relative to parent.
		 */
		public function get extents():Rectangle
		{
			return _extents;
		}

		public function set extents(value:Rectangle):void
		{
			_extents = value;
			refresh();
		}

		public function get progress():Number
		{
			return _progress;
		}

		public function set progress(value:Number):void
		{
			_progress = value;
			refresh();
		}

		public function get tf():TextField
		{
			return _tf;
		}

		public function set tf(value:TextField):void
		{
			_tf = value;
		}
	}
}