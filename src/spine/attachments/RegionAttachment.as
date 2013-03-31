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
	/*import com.badlogic.gdx.graphics.Color;
	import com.badlogic.gdx.graphics.g2d.SpriteBatch;
	import com.badlogic.gdx.graphics.g2d.TextureAtlas.AtlasRegion;
	import com.badlogic.gdx.graphics.g2d.TextureRegion;
	import com.badlogic.gdx.math.MathUtils;
	import com.badlogic.gdx.utils.NumberUtils;*/
	
	import flash.geom.Rectangle;
	
	import spine.Attachment;
	import spine.Bone;
	import spine.Slot;
	
	/** Attachment that displays a texture region. */
	public class RegionAttachment extends Attachment {
		public var x : Number, y : Number, scaleX : Number, scaleY : Number, rotation : Number, width : Number, height : Number;

		private var _region : Rectangle;
		private const _vertices : Vector.<Number> = new Vector.<Number>(20);
		private const _offset : Vector.<Number> = new Vector.<Number>(8);
		
		public function RegionAttachment (name : String) : void {
			super(name);
		}
		
		public function updateOffset () : void {
			/*var width : Number = width();
			var height : Number = height();
			var localX2 : Number = width / 2;
			var localY2 : Number = height / 2;
			var localX : Number = -localX2;
			var localY : Number = -localY2;
			if (region is AtlasRegion) {
				var region : AtlasRegion = this.region as AtlasRegion;
				if (region.rotate) {
					localX += region.offsetX / region.originalWidth * height;
					localY += region.offsetY / region.originalHeight * width;
					localX2 -= (region.originalWidth - region.offsetX - region.packedHeight) / region.originalWidth * width;
					localY2 -= (region.originalHeight - region.offsetY - region.packedWidth) / region.originalHeight * height;
				} else {
					localX += region.offsetX / region.originalWidth * width;
					localY += region.offsetY / region.originalHeight * height;
					localX2 -= (region.originalWidth - region.offsetX - region.packedWidth) / region.originalWidth * width;
					localY2 -= (region.originalHeight - region.offsetY - region.packedHeight) / region.originalHeight * height;
				}
			}
			var scaleX = getScaleX();
			var scaleY = getScaleY();
			localX *= scaleX;
			localY *= scaleY;
			localX2 *= scaleX;
			localY2 *= scaleY;
			var rotation = getRotation();
			var cos = MathUtils.cosDeg(rotation);
			var sin = MathUtils.sinDeg(rotation);
			var x = getX();
			var y = getY();
			var localXCos = localX * cos + x;
			var localXSin = localX * sin;
			var localYCos = localY * cos + y;
			var localYSin = localY * sin;
			var localX2Cos = localX2 * cos + x;
			var localX2Sin = localX2 * sin;
			var localY2Cos = localY2 * cos + y;
			var localY2Sin = localY2 * sin;
			float[] offset = this.offset;
			offset[0] = localXCos - localYSin;
			offset[1] = localYCos + localXSin;
			offset[2] = localXCos - localY2Sin;
			offset[3] = localY2Cos + localXSin;
			offset[4] = localX2Cos - localY2Sin;
			offset[5] = localY2Cos + localX2Sin;
			offset[6] = localX2Cos - localYSin;
			offset[7] = localYCos + localX2Sin;*/
		}
		
		public function set region (region : Rectangle) : void {
			if (region == null) throw new Error("region cannot be null.");
			/*TextureRegion oldRegion = this.region;
			this.region = region;
			float[] vertices = this.vertices;
			if (region instanceof AtlasRegion && ((AtlasRegion)region).rotate) {
				vertices[U2] = region.getU();
				vertices[V2] = region.getV2();
				vertices[U3] = region.getU();
				vertices[V3] = region.getV();
				vertices[U4] = region.getU2();
				vertices[V4] = region.getV();
				vertices[U1] = region.getU2();
				vertices[V1] = region.getV2();
			} else {
				vertices[U1] = region.getU();
				vertices[V1] = region.getV2();
				vertices[U2] = region.getU();
				vertices[V2] = region.getV();
				vertices[U3] = region.getU2();
				vertices[V3] = region.getV();
				vertices[U4] = region.getU2();
				vertices[V4] = region.getV2();
			}
			updateOffset();*/
		}
		
		public function get region () : Rectangle {
			if (region == null) throw new Error("RegionAttachment is not resolved: " + this);
			return region;
		}
		
		override public function draw (displayObject : *, slot : Slot) : void {
			if (region == null) throw new Error("RegionAttachment is not resolved: " + this);
			
			/*Color skeletonColor = slot.getSkeleton().getColor();
			Color slotColor = slot.getColor();
			float color = NumberUtils.intToFloatColor( //
				((int)(255 * skeletonColor.a * slotColor.a) << 24) //
				| ((int)(255 * skeletonColor.b * slotColor.b) << 16) //
				| ((int)(255 * skeletonColor.g * slotColor.g) << 8) //
				| ((int)(255 * skeletonColor.r * slotColor.r)));
			float[] vertices = this.vertices;
			vertices[C1] = color;
			vertices[C2] = color;
			vertices[C3] = color;
			vertices[C4] = color;
			
			updateWorldVertices(slot.getBone());
			
			batch.draw(region.getTexture(), vertices, 0, vertices.length);
			*/
		}
		
		public function updateWorldVertices (bone : Bone) : void {
			/*float[] vertices = this.vertices;
			float[] offset = this.offset;
			float x = bone.getWorldX();
			float y = bone.getWorldY();
			float m00 = bone.getM00();
			float m01 = bone.getM01();
			float m10 = bone.getM10();
			float m11 = bone.getM11();
			vertices[X1] = offset[0] * m00 + offset[1] * m01 + x;
			vertices[Y1] = offset[0] * m10 + offset[1] * m11 + y;
			vertices[X2] = offset[2] * m00 + offset[3] * m01 + x;
			vertices[Y2] = offset[2] * m10 + offset[3] * m11 + y;
			vertices[X3] = offset[4] * m00 + offset[5] * m01 + x;
			vertices[Y3] = offset[4] * m10 + offset[5] * m11 + y;
			vertices[X4] = offset[6] * m00 + offset[7] * m01 + x;
			vertices[Y4] = offset[6] * m10 + offset[7] * m11 + y;*/
		}
		
		public function  get worldVertices () : Vector.<Number> {
			return _vertices;
		}
	}
}