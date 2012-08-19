package com.pblabs.rendering2D
{
	public interface IDisplayObjectSceneLayer
	{
		function get drawOrderFunction():Function;
		function set drawOrderFunction(value:Function):void;
		function markDirty():void;
		function onRender():void;
		function updateOrder():void;
		function add(dor:DisplayObjectRenderer):void;
		function remove(dor:DisplayObjectRenderer):void;
	}
}