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
package spine
{
	import flash.geom.Matrix;

	public class Bone 
	{
		public var x : Number;
		public var y : Number;
		public var rotation : Number;
		public var scaleX : Number = 1;
		public var scaleY : Number = 1;
		
		protected var _parent : Bone;
		protected var _data : BoneData;
		protected var _worldRotation : Number;
		protected var _worldTransform : Matrix = new Matrix();
	
		/** @param parent May be null. */
		public function Bone (data : BoneData, parent :  Bone ) : void{
			if (data == null) 
				throw new Error("data cannot be null.");
			this._data = data;
			this._parent = parent;
			setToBindPose();
		}

		public function clone(parent :  Bone = null):Bone
		{
			var bone : Bone = new Bone(this._data, (parent ? parent : _parent));
			bone.x = this.x;
			bone.y = this.y;
			bone.rotation = this.rotation;
			bone.scaleX = this.scaleX;
			bone.scaleY = this.scaleY;
			return bone;
		}
	
		/** Computes the world SRT using the parent bone and the local SRT. */
		public function updateWorldTransform(flipX : Boolean, flipY : Boolean) : void {
			var parent : Bone = this._parent;
			if (parent != null) {
				var parentTransform : Matrix = parent.worldTransform;
				_worldTransform.translate( x * parentTransform.a + y * parentTransform.b + parentTransform.tx, x * parentTransform.c + y * parentTransform.d + parentTransform.ty);
				_worldTransform.scale( parent.worldScaleX * scaleX, parent.worldScaleY * scaleY );
				_worldRotation = parent.worldRotation + rotation;
				_worldTransform.rotate( _worldRotation );
			} else {
				_worldTransform.translate( x, y );
				_worldTransform.scale( scaleX, scaleY );
				_worldTransform.rotate( rotation );
				_worldRotation = rotation;
			}
			var cos : Number = Math.cos(_worldRotation);
			var sin : Number = Math.sin(_worldRotation);
			_worldTransform.a = cos * _worldTransform.a;
			_worldTransform.c = sin * _worldTransform.a;
			_worldTransform.b = -sin * _worldTransform.d;
			_worldTransform.d = cos * _worldTransform.d;
			
			if (flipX) {
				_worldTransform.a = -_worldTransform.a;
				_worldTransform.b = -_worldTransform.b;
			}
			if (flipY) {
				_worldTransform.c = -_worldTransform.c;
				_worldTransform.d = -_worldTransform.d;
			}
			
		}
	
		public function setToBindPose() : void {
			var data : BoneData = this.data;
			x = data.x;
			y = data.y;
			rotation = data.rotation;
			scaleX = data.scaleX;
			scaleY = data.scaleY;
		}
	
		public function get data () : BoneData {
			return _data;
		}
	
		public function get parent () : Bone {
			return _parent;
		}
	
		public function get worldRotation () : Number{
			return _worldRotation;
		}
	
		public function get worldX () : Number{
			return _worldTransform.tx;
		}
		
		public function get worldY () : Number {
			return _worldTransform.ty;
		}

		public function get worldScaleX () : Number{
			return _worldTransform.a;
		}
	
		public function get worldScaleY () : Number {
			return _worldTransform.d;
		}
	
		public function get worldTransform() : Matrix {
			return _worldTransform.clone();
		}
	
		public function toString () : String{
			return data.name;
		}
	}
}

