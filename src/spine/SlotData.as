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
	import spine.utils.Color;

	public class SlotData {
		public var color : Color = new Color(1, 1, 1, 1);
		
		/** @param attachmentName May be null. */
		public var attachmentName : String;
	
		protected var _name : String;
		protected  var _boneData : BoneData;

		public function SlotData (name : String, boneData : BoneData) {
			if (name == null) throw new Error("name cannot be null.");
			if (boneData == null) throw new Error("bone cannot be null.");
			this._name = name;
			this._boneData = boneData;
		}
	
		public function get name () : String{
			return _name;
		}
	
		public function get boneData () : BoneData{
			return _boneData;
		}
	
		public function toString () : String {
			return _name;
		}
	}
}