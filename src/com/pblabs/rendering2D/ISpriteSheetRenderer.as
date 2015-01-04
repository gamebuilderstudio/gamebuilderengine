package com.pblabs.rendering2D
{
	import com.pblabs.engine.entity.PropertyReference;
	import com.pblabs.rendering2D.spritesheet.ISpriteSheet;

	public interface ISpriteSheetRenderer
	{
		function get spriteSheetProperty():PropertyReference;
		function set spriteSheetProperty(val : PropertyReference):void;
		function get overrideSizePerFrame():Boolean;
		function set overrideSizePerFrame(val : Boolean):void;
		function get spriteSheet():ISpriteSheet;
		function set spriteSheet(sheet : ISpriteSheet):void;
		function get spriteIndex():int;
		function set spriteIndex(val : int):void;
	}
}