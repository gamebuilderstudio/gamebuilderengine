/*******************************************************************************
 * GameBuilder Studio
 * Copyright (C) 2012 GameBuilder Inc.
 * For more information see http://www.gamebuilderstudio.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package spine
{
	import flash.display.BitmapData;
	
	import spine.attachments.Basic2DAttachmentLoader;
	import spine.attachments.ModeEnum;
	import spine.attachments.RegionAttachment;
	import spine.attachments.RegionSequenceAttachment;
	import spine.attachments.StarlingAtlasAttachmentLoader;
	import spine.utils.Color;
	
	import starling.textures.TextureAtlas;
	
	public class SkeletonJson {
		static public var TIMELINE_SCALE : String = "scale";
		static public var TIMELINE_ROTATE : String = "rotate";
		static public var TIMELINE_TRANSLATE : String = "translate";
		static public var TIMELINE_ATTACHMENT : String = "attachment";
		static public var TIMELINE_COLOR : String = "color";
	
		public var scale : Number = 1;

		private var _json : Object;
		private var _attachmentLoader : AttachmentLoader;
	
		public function SkeletonJson (attachmentloader : AttachmentLoader) : void {
			this._attachmentLoader = attachmentloader;
		}
	
		public static function createSkeletonFromAtlas(atlas : TextureAtlas):SkeletonJson
		{
			var textureAttachmentLoader : StarlingAtlasAttachmentLoader = new StarlingAtlasAttachmentLoader(atlas);
			return new SkeletonJson( textureAttachmentLoader );
		}
		
		public static function createBasic2DSkeleton(atlas : TextureAtlas, atlasImageData : BitmapData):SkeletonJson
		{
			var basic2DAttachmentLoader : Basic2DAttachmentLoader = new Basic2DAttachmentLoader(atlas, atlasImageData);
			return new SkeletonJson( basic2DAttachmentLoader );
		}

		public function readSkeletonData (jsonData : String, skeletonName : String) : SkeletonData {
			if (jsonData == null) throw new Error("file cannot be null.");
			if (skeletonName == null) throw new Error("Skeleton name cannot be null.");
	
			var skeletonData : SkeletonData = new SkeletonData();
			skeletonData.name = skeletonName;
			
			_json = JSON.parse( jsonData );
	
			var boneData : BoneData;
			// Bones.
			var bonesMap : Array = _json.bones;
			var len : int = bonesMap.length;
			for(var i : int = 0; i < len; i++) {
				var entry : String = bonesMap[i].name;
				var parent : BoneData = null;
				var parentName : String = bonesMap[i]["parent"];
				if (parentName != null) {
					parent = skeletonData.findBone(parentName);
					if (parent == null) throw new Error("Bone not found: " + parentName);
				}
				boneData = new BoneData(entry, parent);
				boneData.length = Number(bonesMap[i]["length"]) || 0;
				boneData.x = Number(bonesMap[i]["x"]) || 0;
				boneData.y = Number(bonesMap[i]["y"]) || 0;
				boneData.rotation = Number(bonesMap[i]["rotation"]) || 0;
				boneData.scaleX = Number(bonesMap[i]["scaleX"]) || 1;
				boneData.scaleY = Number(bonesMap[i]["scaleY"]) || 1;
				skeletonData.addBone(boneData);
			}
			// Slots.
			var slotMap : Array = _json.slots;
			if (slotMap != null) {
				len = slotMap.length;
				for(i = 0; i < len; i++) {
					var boneName : String = slotMap[i]["bone"];
					boneData = skeletonData.findBone(boneName);
					if (boneData == null) throw new Error("Bone not found: " + boneName);
					var slotData : SlotData = new SlotData(slotMap[i]["name"], boneData);
	
					var color : Color = Color.valueOfHex( slotMap[i]["color"] );
					if (color != null) slotData.color = color;
	
					slotData.attachmentName = slotMap[i]["attachment"];
					skeletonData.addSlot(slotData);
				}
			}
	
			// Skins.
			var skinMap : Object = _json.skins;
			if (skinMap != null) {
				for (entry in skinMap) {
					var skin : Skin = new Skin(entry);
					var skinSlotsMap : Object = skinMap[entry];
					for (var slotEntry : String in skinSlotsMap) {
						var slotIndex : int = skeletonData.findSlotIndex(slotEntry);
						var attachmentsMap : Object = skinSlotsMap[slotEntry];
						for (var attachmentEntry : String in attachmentsMap) {
							var attachment : Attachment = readAttachment(attachmentEntry, attachmentsMap[attachmentEntry]);
							skin.addAttachment(slotIndex, attachmentEntry, attachment);
						}
					}
					
					skeletonData.addSkin(skin);
					if (skin.name == "default") skeletonData.defaultSkin = skin;
				}
			}
	
			/*
			skeletonData.bones.shrink();
			skeletonData.slots.shrink();
			skeletonData.skins.shrink();*/
			return skeletonData;
		}

		private function readAttachment (name : String, attachmentObject : Object) : Attachment {
			name = attachmentObject["name"] || name;
			
			var type : AttachmentTypeEnum = AttachmentTypeEnum.getRegionType( attachmentObject["type"] );
			var attachment : Attachment = _attachmentLoader.newAttachment(type, name);
			
			if (attachment is RegionSequenceAttachment) {
				var regionSequenceAttachment : RegionSequenceAttachment = attachment as RegionSequenceAttachment;
				
				var fps : Number = attachmentObject["fps"];
				if (isNaN(fps)) throw new Error("Region sequence attachment missing fps: " + name);
				regionSequenceAttachment.frameTime = fps;
				
				var modeString : String = attachmentObject["mode"];
				regionSequenceAttachment.mode = modeString == null ? ModeEnum.FORWARD : ModeEnum.getMode(modeString);
			}
			
			if (attachment is RegionAttachment) {
				var regionAttachment : RegionAttachment = attachment as RegionAttachment;
				regionAttachment.x = (attachmentObject["x"] * scale) || 0;
				regionAttachment.y = (attachmentObject["y"] * scale) || 0;
				regionAttachment.scaleX = attachmentObject["scaleX"] || 1;
				regionAttachment.scaleY = attachmentObject["scaleY"] || 1;
				regionAttachment.rotation = attachmentObject["rotation"] || 0;
				regionAttachment.width = attachmentObject["width"] * scale;
				regionAttachment.height = attachmentObject["height"] * scale;
				regionAttachment.updateOffset();
			}
			
			return attachment;
		}
	
		public function readAnimation (jsonData : String, skeletonData : SkeletonData, animationName : String) : Animation {
			if (jsonData == null) throw new Error("file cannot be null.");
			if (skeletonData == null) throw new Error("skeleton Data cannot be null.");
			if (animationName == null) throw new Error("animation name cannot be null.");
	
			var animationJsonObject : Object = JSON.parse( jsonData );
			
			var timelines : Vector.<Timeline> = new Vector.<Timeline>();
			var duration : Number = 0;
			var keyframeIndex : int;
			var values : Array;
			var valLen : int;
			var time : Number;
			var timelineMap : Object;
			var timelineName : String;
			var timelineEntry : String
			
			var bonesMap : Object = animationJsonObject.bones;
			
			for (var entry : String in bonesMap) {
				var boneName : String = entry;
				var boneIndex : int = skeletonData.findBoneIndex(boneName);
				if (boneIndex == -1) throw new Error("Bone not found: " + boneName);
				timelineMap = bonesMap[entry];
				for (timelineEntry in timelineMap) {
					values = timelineMap[timelineEntry];
					valLen = values.length;
					timelineName = timelineEntry;
					if (timelineName == TIMELINE_ROTATE) {
						var timeline : RotateTimeline = new RotateTimeline(valLen);
						timeline.setBoneIndex(boneIndex);
						
						keyframeIndex = 0;
						for (var i : int = 0; i < valLen; i++) {
							time = values[i]["time"];
							timeline.setFrame(keyframeIndex, time, Number(values[i]["angle"]));
							readCurve(timeline, keyframeIndex, values[i]);
							keyframeIndex++;
						}
						timelines.push(timeline);
						duration = Math.max(duration, timeline.getFrames()[timeline.getFrameCount() * 2 - 2]);
						
					} else if (timelineName == TIMELINE_TRANSLATE || timelineName == TIMELINE_SCALE) {
						var transTimeline : TranslateTimeline;
						var timelineScale : Number = 1;
						if (timelineName == TIMELINE_SCALE)
							transTimeline = new ScaleTimeline(valLen);
						else {
							transTimeline = new TranslateTimeline(valLen);
							timelineScale = scale;
						}
						transTimeline.setBoneIndex(boneIndex);
						
						keyframeIndex = 0;
						for (i = 0; i < valLen; i++) {
							time = values[i]["time"];
							var x : Number = values[i]["x"], y : Number = values[i]["y"];
							transTimeline.setFrame(keyframeIndex, time, (isNaN(x)) ? 0 : (x * timelineScale), (isNaN(y)) ? 0 : (y * timelineScale) );
							readCurve(transTimeline, keyframeIndex, values[i]);
							keyframeIndex++;
						}
						timelines.push(transTimeline);
						duration = Math.max(duration, transTimeline.getFrames()[transTimeline.getFrameCount() * 3 - 3]);
						
					} else
						throw new Error("Invalid timeline type for a bone: " + timelineName + " (" + boneName + ")");
				}
			}
			
			var slotsMap : Object = animationJsonObject.slots;
			if (slotsMap != null) {
				for (var slotEntry : String in slotsMap) {
					var slotName : String = slotEntry;
					var slotIndex : int = skeletonData.findSlotIndex(slotName);
					
					timelineMap = slotsMap[slotEntry];
					for (timelineEntry in timelineMap) {
						values = timelineMap[timelineEntry];
						valLen = values.length;

						timelineName = timelineEntry;
						if (timelineName == TIMELINE_COLOR) {
							var colorTimeline : ColorTimeline = new ColorTimeline(valLen);
							colorTimeline.setSlotIndex(slotIndex);
							
							keyframeIndex = 0;
							for (i = 0; i < valLen; i++) {
								time = values[i]["time"];
								var color : Color = Color.valueOfHex(values[i]["color"]);
								colorTimeline.setFrame(keyframeIndex, time, color.r, color.g, color.b, color.a);
								readCurve(colorTimeline, keyframeIndex, values[i]);
								keyframeIndex++;
							}
							timelines.push(colorTimeline);
							duration = Math.max(duration, colorTimeline.getFrames()[colorTimeline.getFrameCount() * 5 - 5]);
							
						} else if (timelineName == TIMELINE_ATTACHMENT) {
							var attachmentTimeline : AttachmentTimeline = new AttachmentTimeline(valLen);
							attachmentTimeline.slotIndex = slotIndex;
							
							keyframeIndex = 0;
							for (i = 0; i < valLen; i++) {
								time = values[i]["time"];
								attachmentTimeline.setFrame(keyframeIndex++, time, values[i]["name"]);
							}
							timelines.push(attachmentTimeline);
							duration = Math.max(duration, attachmentTimeline.getFrames()[attachmentTimeline.getFrameCount() - 1]);
							
						} else
							throw new Error("Invalid timeline type for a slot: " + timelineName + " (" + slotName + ")");
					}
				}
			}
			
			//timelines.shrink();
			var animation : Animation = new Animation(timelines, duration);
			animation.name = animationName;
			return animation;
		}
	
		private function readCurve (timeline : CurveTimeline, keyframeIndex : int, valueMap : Object) : void {
			var curveObject : Object = valueMap["curve"] as Array;
			if (curveObject == null) return;
			if (curveObject == "stepped"){
				timeline.setStepped(keyframeIndex);
			}else if(curveObject is Array) {
				var curve : Array = curveObject as Array;
				timeline.setCurve(keyframeIndex, curve[0], curve[1], curve[2], curve[3]);
			}
		}
	}
}
