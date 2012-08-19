package com.pblabs.rendering2D
{
	import com.pblabs.engine.resource.DataResource;
	import com.pblabs.engine.resource.ImageResource;

	public interface ITextRenderer
	{
		function get fontImage():ImageResource;
		function set fontImage(img : ImageResource):void;

		function get fontData():DataResource;
		function set fontData(data : DataResource):void;

		function get fontColor():uint;
		function set fontColor(val : uint):void
		
		function get fontSize():Number;
		function set fontSize(val : Number):void;
	}
}