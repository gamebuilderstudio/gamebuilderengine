package com.pblabs.starling2D.spritesheet
{
	import com.pblabs.rendering2D.spritesheet.CachedFramesData;
	import com.pblabs.rendering2D.spritesheet.ISpriteSheetDivider;
	
	import flash.geom.Rectangle;
	
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class CachedFramesDataG2D extends CachedFramesData
	{
		public var atlas : TextureAtlas;
		
		public function CachedFramesDataG2D(frames:Array, fileName:String, divider:ISpriteSheetDivider, bounds:Rectangle, atlas : TextureAtlas)
		{
			super(frames, fileName, divider, bounds);
			this.atlas = atlas;
		}
		
		override public function destroy():void
		{
			//TODO: May Need To Release Textures
			/*var len : int = frames.length;
			for (var i : int = 0; i < len; i++)
			{
				var texture : Texture = frames[i] as Texture;
				texture
				frames[i].dispose();
				frames.splice(0,1);
			}*/
			atlas.dispose();
			super.destroy();
		}
			
	}
}