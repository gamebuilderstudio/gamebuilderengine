package com.pblabs.rendering2D
{
	import com.pblabs.rendering2D.spritesheet.ISpriteSheet;

	public interface ISpriteSheetRenderer
	{
		function get spriteSheet():ISpriteSheet;
		function set spriteSheet(sheet : ISpriteSheet):void;
		function get spriteIndex():int;
		function set spriteIndex(val : int):void;
	}
}