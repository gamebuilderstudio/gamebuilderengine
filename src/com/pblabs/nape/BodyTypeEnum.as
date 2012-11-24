package com.pblabs.nape
{ 
	import com.pblabs.engine.serialization.Enumerable;
	import com.pblabs.engine.serialization.ISerializable;
	
	import flash.utils.Dictionary;
	
	import nape.phys.BodyType;
	
	//Serializable BodyType wrapper 
	public class BodyTypeEnum extends Enumerable
	{
		public static const DYNAMIC:BodyTypeEnum = new BodyTypeEnum();
		public static const KINEMATIC:BodyTypeEnum = new BodyTypeEnum();
		public static const STATIC:BodyTypeEnum = new BodyTypeEnum();
		 
		public function BodyTypeEnum()
		{
			super();
		}
		
		private static var _typeMap:Dictionary = null;
		
		override public function get typeMap():Dictionary
		{
			if (!_typeMap)
			{
				_typeMap = new Dictionary();
				_typeMap["DYNAMIC"] = DYNAMIC;
				_typeMap["KINEMATIC"] = KINEMATIC;
				_typeMap["STATIC"] = STATIC;
			}
			
			return _typeMap;
		}
		
		override public function get defaultType():Enumerable
		{
			return DYNAMIC;
		}
	}
}