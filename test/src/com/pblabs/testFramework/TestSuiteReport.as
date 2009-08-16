package com.pblabs.testFramework
{
	public class TestSuiteReport
	{
		public var name : String;
		public var errors : uint = 0;
		public var failures : uint = 0;
		public var tests : uint = 0;
		public var time : Number = 0;
		public var methods : Array = new Array()
	}
}