package com.pblabs.engine.version
{
	public class VersionDetails extends Object
	{
		public var type:String;
		public var version:String;
		
		public function toString():String
		{
			return type + (version ? " ("+version+")" : "");	
		}
	}
}