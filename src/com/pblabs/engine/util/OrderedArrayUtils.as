package com.pblabs.engine.util
{
	import com.pblabs.engine.core.OrderedArray;

	public final class OrderedArrayUtils
	{
		public function OrderedArrayUtils()
		{
		}
		
		public static function insertItemInArray(src : OrderedArray, item : Object, index : int = 0):void
		{
			var len : int = src.length;
			for (var i : int = src.length; i > index; i--)
			{
				src[i+1] = src[i];
			}
			src[index] = item;
		}
	}
}