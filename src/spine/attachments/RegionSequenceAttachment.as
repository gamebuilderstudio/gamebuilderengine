/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2012 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package spine.attachments
{
	import flash.geom.Rectangle;
	
	import spine.Slot;
	import spine.utils.MathUtils;
	
	/** Attachment that displays various texture regions over time. */
	public class RegionSequenceAttachment extends RegionAttachment {
		protected var _mode : ModeEnum;
		protected var _frameTime : Number;
		protected var _frameIndex : int;
		protected var _frames : Vector.<Rectangle>;
		
		public function RegionSequenceAttachment (name : String) : void {
			super(name);
		}
		
		override public function draw ( displayObject : *, slot : Slot) : void {
			if (_frames == null) throw new Error("RegionSequenceAttachment is not resolved: " + this);
			
			_frameIndex = int(slot.attachmentTime / _frameTime);
			switch (_mode) {
				case ModeEnum.FORWARD:
					_frameIndex = Math.min(_frames.length - 1, _frameIndex);
					break;
				case ModeEnum.FORWARD_LOOP:
					_frameIndex = _frameIndex % _frames.length;
					break;
				case ModeEnum.PINGPONG:
					_frameIndex = _frameIndex % (_frames.length * 2);
					if (_frameIndex >= _frames.length) _frameIndex = _frames.length - 1 - (_frameIndex - _frames.length);
					break;
				case ModeEnum.RANDOM:
					_frameIndex = MathUtils.randomRange(0, _frames.length - 1);
					break;
				case ModeEnum.BACKWARD:
					_frameIndex = Math.max(_frames.length - _frameIndex - 1, 0);
					break;
				case ModeEnum.BACKWARD_LOOP:
					_frameIndex = _frameIndex % _frames.length;
					_frameIndex = _frames.length - _frameIndex - 1;
					break;
			}
			//region = _frames[_frameIndex];
			super.draw(displayObject, slot);
		}
		
		public function get frameIndex () : int {
			return _frameIndex;
		}

		/** May be null if the attachment is not resolved. */
		public function get frames () : Vector.<Rectangle> {
			if (_frames == null) throw new Error("RegionSequenceAttachment is not resolved: " + this);
			return _frames;
		}
		
		public function set frames (frames : Vector.<Rectangle>) : void {
			this._frames = frames;
		}
		
		/** Sets the time in seconds each frame is shown. */
		public function set frameTime (frameTime : Number) : void {
			this._frameTime = frameTime;
		}
		
		public function set mode (mode : ModeEnum) : void {
			this._mode = mode;
		}
	}
}
