package com.pblabs.rendering2D.ui
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	/**
	 * Simple Scroll Bar for use in creating simple UIs.
	 * 
	 * Change properties and call refresh() for them to take effect.
	 */
	public class PBScrollBar extends Sprite
	{
		protected var _extents:Rectangle;
		protected var _track:Sprite;
		protected var _thumb:Sprite;
		
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
			_thumb.addEventListener(MouseEvent.CLICK, onThumbClick, false, 0, true);
		}
		
		protected function onTrackClick(event:MouseEvent):void
		{
			trace("Track Clicked");
		}
		
		protected function onThumbClick(event:MouseEvent):void
		{
			trace("Thumb Clicked");
		}
		
		/**
		 * Applies all changes and updates appearance of the scroll bar.
		 * 
		 * We have this as an explicit function call so that there
		 * isn't any overhead if many properties are changed.
		 */
		public function refresh():void
		{
			// Redraw our track.
			_track.graphics.clear();
			_track.graphics.beginFill(0xEEEEEE,0);
			_track.graphics.drawRect(_extents.x, _extents.y, _extents.width, _extents.height);
			_track.graphics.endFill();
			
			// TODO Calculate the thumb position
			
			// Redraw our thumb.
			_thumb.graphics.clear();
			_thumb.graphics.beginFill(0xCCCCCC);
			_thumb.graphics.drawRoundRect(_extents.x+1, _extents.y+1, _extents.width-2, _extents.height/10, _extents.width, _extents.width);
			_thumb.graphics.endFill();
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

	}
}