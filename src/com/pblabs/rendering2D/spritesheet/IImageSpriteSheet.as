package com.pblabs.rendering2D.spritesheet
{
	import com.pblabs.engine.resource.ImageResource;

	/**
	 * Marker interface to denote a sprite sheet generated from an ImageResource
	 */
	public interface IImageSpriteSheet extends ISpriteSheet
	{
		/**
		 * The image resource to use for this sprite sheet.
		 */
		function set image(value:ImageResource):void
		function get image():ImageResource
	}
}