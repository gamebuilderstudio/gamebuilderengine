package com.pblabs.engine.util
{
	import flash.utils.describeType;

	public final class DynamicObjectUtil
	{
		public function DynamicObjectUtil()
		{
		}

		public static function isDynamic(object : *) : Boolean
		{
			var type:XML = describeType(object);
			return type.@isDynamic.toString() == "true";
		}
		
		public static function clearDynamicObject(source:Object):void
		{
			var p:String;
			
			for (p in source) {
				delete source[p];
			}
		}
		
		public static function clearFromDynamicObject(source:Object, destination:Object):void
		{
			var p:String;
			
			for (p in source) {
				delete destination[p];
			}
		}

		public static function copyDynamicObject(source:Object, destination:Object):void
		{
			var p:String;
			
			for (p in source) {
				destination[p] = source[p];
			}
		}
		
		public static function copyData(source:Object, destination:Object, objectDescription : XML = null):void {
			
			//copies data from commonly named properties and getter/setter pairs
			if((source) && (destination)) {
				var destDynamic : Boolean = isDynamic(destination);
				try {
					var sourceInfo:XML = objectDescription ? objectDescription : describeType(source);
					var prop:XML;
					
					for each(prop in sourceInfo.variable) {
						
						if(prop.@name in destination || destDynamic) {
							destination[prop.@name] = source[prop.@name];
						}
						
					}
					
					for each(prop in sourceInfo.accessor) {
						if(prop.@access == "readwrite") {
							if(prop.@name in destination || destDynamic) {
								destination[prop.@name] = source[prop.@name];
							}
							
						}
					}
				}
				catch (err:Object) {
					//;
				}
			}
		}
	}
}