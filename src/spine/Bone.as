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
	import flash.geom.Matrix;
	
	import spine.utils.MathUtils;

	public class Bone 
	{
		public var x : Number = 0;
		public var y : Number = 0;
		public var rotation : Number;
		public var scaleX : Number = 1;
		public var scaleY : Number = 1;
		
		protected var _m00 : Number, _m01 : Number; // a b (x)
		protected var _m10 : Number, _m11 : Number; // c d (y)
		protected var _parent : Bone;
		protected var _data : BoneData;
		protected var _worldScaleX : Number;
		protected var _worldScaleY : Number;
		protected var _worldX : Number;
		protected var _worldY : Number;
		protected var _worldRotation : Number;
		protected var _worldTransform : Vector.<Number> = new Vector.<Number>();
	
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
				_worldX = x * parent.m00 + y * parent.m01 + parent.worldX;
				_worldY = x * parent.m10 + y * parent.m11 + parent.worldY;
				_worldScaleX = parent.worldScaleX * scaleX;
				_worldScaleY = parent.worldScaleY * scaleY;
				_worldRotation = parent.worldRotation + rotation;
			} else {
				_worldX = x;
				_worldY = y;
				_worldScaleX = scaleX;
				_worldScaleY = scaleY;
				_worldRotation = rotation;
			}

			var cos : Number = Math.cos(MathUtils.getRadiansFromDegrees(_worldRotation));
			var sin : Number = Math.sin(MathUtils.getRadiansFromDegrees(_worldRotation));
			_m00 = cos * _worldScaleX;
			_m10 = sin * _worldScaleX;
			_m01 = -sin * _worldScaleY;
			_m11 = cos * _worldScaleY;
			
			if (flipX) {
				_m00 = -_m00;
				_m01 = -_m01;
			}
			if (flipY) {
				_m10 = -_m10;
				_m11 = -_m11;
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
	
		public function get m00 () : Number{
			return _m00;
		}
		public function get m01 () : Number{
			return _m01;
		}
		public function get m10 () : Number{
			return _m10;
		}
		public function get m11 () : Number{
			return _m11;
		}

		public function get worldRotation () : Number{
			return _worldRotation;
		}
	
		public function get worldX () : Number{
			return _worldX;
		}
		
		public function get worldY () : Number {
			return _worldY;
		}

		public function get worldScaleX () : Number{
			return _worldScaleX;
		}
	
		public function get worldScaleY () : Number {
			return _worldScaleY;
		}
	
		public function get worldTransform() : Vector.<Number> {
			if (_worldTransform == null) throw new Error("worldTransform cannot be null.");
			/*_worldTransform[_m00] = _m00;
			_worldTransform[_m01] = m01;
			_worldTransform[M02] = worldX;
			_worldTransform[M10] = m10;
			_worldTransform[M11] = m11;
			_worldTransform[M12] = worldY;
			_worldTransform[M20] = 0;
			_worldTransform[M21] = 0;
			_worldTransform[M22] = 1;*/
			return _worldTransform;
		}
	
		public function toString () : String{
			return data.name;
		}
	}
}

