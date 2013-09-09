package com.pblabs.rendering2D
{
	import com.pblabs.rendering2D.spritesheet.ISpriteSheet;

	public interface ISpriteSheetRenderer
	{
		function get overrideSizePerFrame():Boolean;
		function set overrideSizePerFrame(val : Boolean):void;
		function get spriteSheet():ISpriteSheet;
		function set spriteSheet(sheet : ISpriteSheet):void;
		function get spriteIndex():int;
		function set spriteIndex(val : int):void;
	}
}