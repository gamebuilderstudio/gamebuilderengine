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
	import flash.utils.Dictionary;

	public class AttachmentTypeEnum
	{
		public static const REGION : AttachmentTypeEnum = new AttachmentTypeEnum('region');
		public static const REGION_SEQUENCE : AttachmentTypeEnum = new AttachmentTypeEnum('regionSequence');
		
		private var _name : String;
		public static var _types : Dictionary;
		
		public function AttachmentTypeEnum(name : String)
		{
			_name = name;
		}
		
		public function get name():String { return _name; }
		
		public static function getRegionType(type : String) : AttachmentTypeEnum
		{
			if(!_types){
				_types = new Dictionary();
				_types[REGION.name] = REGION;
				_types[REGION_SEQUENCE.name] = REGION_SEQUENCE;
			}
			
			return _types[type];
		}
	}
}