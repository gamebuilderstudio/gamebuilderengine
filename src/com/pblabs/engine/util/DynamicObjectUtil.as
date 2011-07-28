package com.pblabs.engine.util
{
	import flash.utils.describeType;

	public final class DynamicObjectUtil
	{
		public function DynamicObjectUtil()
		{
		}

		public static function clearDynamicObject(source:Object):void
		{
			var p:String;
			
			for (p in source) {
				delete source[p];
			}
		}
		
		public static function copyDynamicObject(source:Object, destination:Object):void
		{
			var p:String;
			
			for (p in source) {
				destination[p] = source[p];
			}
		}
		
		public static function copyData(source:Object, destination:Object):void {
			
			//copies data from commonly named properties and getter/setter pairs
			if((source) && (destination)) {
				
				try {
					var sourceInfo:XML = describeType(source);
					var prop:XML;
					
					for each(prop in sourceInfo.variable) {
						
						if(destination.hasOwnProperty(prop.@name)) {
							destination[prop.@name] = source[prop.@name];
						}
						
					}
					
					for each(prop in sourceInfo.accessor) {
						if(prop.@access == "readwrite") {
							if(destination.hasOwnProperty(prop.@name)) {
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