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
			super.destroy();
			if(this.atlas){
				this.atlas.dispose();
				this.atlas = null;
			}
		}
	}
}