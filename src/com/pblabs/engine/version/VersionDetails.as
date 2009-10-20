package com.pblabs.engine.version
{
    /**
     * Utility class to store version information. 
     */
	public class VersionDetails
	{
		public var type:String;
		public var flexVersion:FlexSDKVersion;
		
		public function toString():String
		{
			return type + (flexVersion ? " ("+flexVersion+")" : "");	
		}
	}
}