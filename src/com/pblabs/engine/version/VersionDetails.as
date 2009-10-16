package com.pblabs.engine.version
{
	public class VersionDetails extends Object
	{
		public var type:String;
		public var flexVersion:FlexSDKVersion;
		
		public function toString():String
		{
			return type + (flexVersion ? " ("+flexVersion+")" : "");	
		}
	}
}