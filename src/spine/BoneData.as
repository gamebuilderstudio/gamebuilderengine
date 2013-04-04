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
		
	public class BoneData {
		public var length : Number = 0;
		public var x : Number = 0;
		public var y : Number = 0;
		public var rotation : Number = 0;
		public var scaleX : Number = 1;
		public var scaleY : Number = 1;
	
		protected var _name : String;
		protected var _parent : BoneData;
	
		/** @param parent May be null. */
		public function BoneData (name : String, parent : BoneData = null) : void {
			if (name == null) 
				throw new Error("name cannot be null.");
			this._name = name;
			this._parent = parent;
		}
	
		public function clone(parent : BoneData):BoneData
		{
			var data : BoneData = new BoneData(this.name, parent); 
			data.length = this.length;
			data.x = this.x;
			data.y = this.y;
			data.rotation = this.rotation;
			data.scaleX = this.scaleX;
			data.scaleY = this.scaleY;
			return data;
		}
	
		/** @return May be null. */
		public function get parent () : BoneData{
			return _parent;
		}
	
		public function get name () : String {
			return _name;
		}
	
		public function toString () : String{
			return name;
		}
	}
}