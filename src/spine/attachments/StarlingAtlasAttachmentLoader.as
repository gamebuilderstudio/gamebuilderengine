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
	
	import spine.Attachment;
	import spine.AttachmentLoader;
	import spine.AttachmentTypeEnum;
	
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class StarlingAtlasAttachmentLoader implements AttachmentLoader {
		private var _atlas : TextureAtlas;
		
		public function StarlingAtlasAttachmentLoader (atlas : TextureAtlas) : void {
			if (atlas == null) throw new Error("atlas cannot be null.");
			this._atlas = atlas;
		}
		
		public function newAttachment (type : AttachmentTypeEnum, name : String) : Attachment {
			if(!type)
				type = AttachmentTypeEnum.REGION;
			
			var attachment : Attachment = null;
			switch (type) {
				case AttachmentTypeEnum.REGION:
					attachment = new StarlingRegionAttachment(name);
					break;
				case AttachmentTypeEnum.REGION_SEQUENCE:
					//TODO : Support Region sequence
					//attachment = new RegionSequenceAttachment(name);
					break;
				default:
					throw new Error("Unknown attachment type: " + type.name);
			}
			
			if (attachment is StarlingRegionAttachment) {
				var region : Rectangle = _atlas.getRegion(attachment.name);
				var texture : Texture = _atlas.getTexture(attachment.name);
				var frame : Rectangle = _atlas.getFrame(attachment.name);

				if (texture == null)
					throw new Error("Region not found in atlas: " + attachment + " (" + type + " attachment: " + name + ")");
				(attachment as StarlingRegionAttachment).region = region;
				(attachment as StarlingRegionAttachment).texture = texture;
				(attachment as StarlingRegionAttachment).frame = frame;
			}
			
			return attachment;
		}
	}
}