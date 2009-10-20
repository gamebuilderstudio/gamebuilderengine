package com.pblabs.rendering2D
{
	import flash.geom.Point;

    /**
     * Helper class for controlling alignment of scene relative to its position.
     */
	public final class SceneAlignment
	{
		public static const TOP_LEFT:String = "topLeft";
		public static const TOP_RIGHT:String = "topRight";
		public static const BOTTOM_LEFT:String = "bottomLeft";
		public static const BOTTOM_RIGHT:String = "bottomRight";
		public static const CENTER:String = "center";
		
		public static const DEFAULT_ALIGNMENT:String = CENTER;
		
		// todo add additional alignments
		
        /**
         * Given an alignment constant from this class, calculate 
         * @param outPoint
         * @param alignment
         * @param sceneWidth
         * @param sceneHeight
         * 
         */
		public static function calculate(outPoint:Point, alignment:String, sceneWidth:int, sceneHeight:int):void
		{
			switch(alignment)
			{
				case CENTER:
					outPoint.x = sceneWidth * 0.5;
					outPoint.y = sceneHeight * 0.5;
					break;
				case TOP_LEFT:
					outPoint.x = outPoint.y = 0;
					break;
				case TOP_RIGHT:
					outPoint.x = sceneWidth;
					outPoint.y = 0;
					break;
				case BOTTOM_LEFT:
					outPoint.x = 0;
					outPoint.y = sceneHeight;
					break;
				case BOTTOM_RIGHT:
					outPoint.x = sceneWidth;
					outPoint.y = sceneHeight;
					break;
			}
		}
	}
}