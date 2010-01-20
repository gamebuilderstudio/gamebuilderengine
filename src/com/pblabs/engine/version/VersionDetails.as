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
			return "PushButton Engine - r" + stripKeywords(BuildVersion.REV_NUMBER) +" - "
				+ type + (flexVersion ? " ("+flexVersion+")" : "") 
				+ " - " + Security.sandboxType;	
		}
		
		/**
		 * Used to strip out non-numeric characters generated from svn:keywords 
		 * from the revNumber string.
		 */ 
		protected function stripKeywords(str:String):String
		{
			var min:int = "0".charCodeAt(0);
			var max:int = "9".charCodeAt(0);
			var tmp:String = "";
			for(var i:int=0; i < str.length; i++)
			{
				var c:int = str.charCodeAt(i);
				if(c >= min && c <= max) tmp += str.charAt(i);
			}
			
			return tmp;
		}
	}
}