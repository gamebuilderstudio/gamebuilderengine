/*******************************************************************************
 * Copyright (c) 2013, Esoteric Software
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
