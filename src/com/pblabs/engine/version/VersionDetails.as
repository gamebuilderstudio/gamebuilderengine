package com.pblabs.engine.version
{
	import flash.system.Security;
	
    /**
     * Utility class to store version information. 
     */
	public class VersionDetails
	{
		public var type:String;
		public var flexVersion:FlexSDKVersion;
		
		public function toString():String
		{
			return "PushButton Engine - " + BuildVersion.BUILD_NUMBER +" - "
				+ type + (flexVersion ? " ("+flexVersion+")" : "") 
				+ " - " + Security.sandboxType;	
		}
	}
}