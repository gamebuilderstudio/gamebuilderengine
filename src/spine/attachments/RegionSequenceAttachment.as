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
		private var _mode : ModeEnum;
		private var _frameTime : Number;
		private var _regions : Vector.<Rectangle>;
		
		public function RegionSequenceAttachment (name : String) : void {
			super(name);
		}
		
		override public function draw ( displayObject : *, slot : Slot) : void {
			if (_regions == null) throw new Error("RegionSequenceAttachment is not resolved: " + this);
			
			var frameIndex : int = int(slot.attachmentTime / _frameTime);
			switch (_mode) {
				case ModeEnum.FORWARD:
					frameIndex = Math.min(_regions.length - 1, frameIndex);
					break;
				case ModeEnum.FORWARD_LOOP:
					frameIndex = frameIndex % _regions.length;
					break;
				case ModeEnum.PINGPONG:
					frameIndex = frameIndex % (_regions.length * 2);
					if (frameIndex >= _regions.length) frameIndex = _regions.length - 1 - (frameIndex - _regions.length);
					break;
				case ModeEnum.RANDOM:
					frameIndex = MathUtils.randomRange(0, _regions.length - 1);
					break;
				case ModeEnum.BACKWARD:
					frameIndex = Math.max(_regions.length - frameIndex - 1, 0);
					break;
				case ModeEnum.BACKWARD_LOOP:
					frameIndex = frameIndex % _regions.length;
					frameIndex = _regions.length - frameIndex - 1;
					break;
			}
			region = _regions[frameIndex];
			super.draw(displayObject, slot);
		}
		
		/** May be null if the attachment is not resolved. */
		public function get regions () : Vector.<Rectangle> {
			if (_regions == null) throw new Error("RegionSequenceAttachment is not resolved: " + this);
			return _regions;
		}
		
		public function set regions (regions : Vector.<Rectangle>) : void {
			this._regions = regions;
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
