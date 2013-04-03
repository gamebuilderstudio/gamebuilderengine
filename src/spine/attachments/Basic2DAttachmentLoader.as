/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2012 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
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
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	import spine.Attachment;
	import spine.AttachmentLoader;
	import spine.AttachmentTypeEnum;
	
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class Basic2DAttachmentLoader implements AttachmentLoader {
		private var _atlas : TextureAtlas;
		private var _image : BitmapData;
		
		public function Basic2DAttachmentLoader (atlas : TextureAtlas, image : BitmapData) : void {
			if (atlas == null) throw new Error("atlas cannot be null.");
			this._atlas = atlas;
			this._image = image;
		}
		
		public function newAttachment (type : AttachmentTypeEnum, name : String) : Attachment {
			if(!type)
				type = AttachmentTypeEnum.REGION;
			
			var attachment : Attachment = null;
			switch (type) {
				case AttachmentTypeEnum.REGION:
					attachment = new Basic2DRegionAttachment(name);
					break;
				case AttachmentTypeEnum.REGION_SEQUENCE:
					//TODO : Support Region sequence
					//attachment = new RegionSequenceAttachment(name);
					break;
				default:
					throw new Error("Unknown attachment type: " + type.name);
			}
			
			if (attachment is Basic2DRegionAttachment) {
				var region : Rectangle = _atlas.getRegion(attachment.name);
				var frame : Rectangle = _atlas.getFrame(attachment.name);

				if (_image == null)
					throw new Error("Image not found for atlas: " + attachment + " (" + type + " attachment: " + name + ")");
				(attachment as Basic2DRegionAttachment).frame = frame;
				(attachment as Basic2DRegionAttachment).region = region;
				(attachment as Basic2DRegionAttachment).image = _image;
			}
			
			return attachment;
		}
	}
}